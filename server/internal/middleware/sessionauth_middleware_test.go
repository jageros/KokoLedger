package middleware

import (
	"context"
	"database/sql"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"koko/internal/model"
	"koko/internal/pkg/authsession"
)

type fakeSessionStore struct {
	session *model.AuthSessions
	err     error
	touched bool
}

func (f *fakeSessionStore) FindOne(_ context.Context, _ string) (*model.AuthSessions, error) {
	return f.session, f.err
}

func (f *fakeSessionStore) Touch(_ context.Context, _ string) error {
	f.touched = true
	return nil
}

func TestSessionAuthMiddleware(t *testing.T) {
	token := "token"
	valid := &model.AuthSessions{
		Id:        "session-1",
		UserId:    "user-1",
		TokenHash: authsession.TokenHash(token),
		ExpiresAt: time.Now().Add(time.Hour),
	}

	tests := []struct {
		name       string
		ctx        context.Context
		header     string
		session    *model.AuthSessions
		storeErr   error
		wantStatus int
		wantNext   bool
		wantTouch  bool
	}{
		{name: "missing claims", ctx: context.Background(), header: "Bearer " + token, session: valid, wantStatus: http.StatusUnauthorized},
		{name: "missing token", ctx: claimsContext("user-1", "session-1"), session: valid, wantStatus: http.StatusUnauthorized},
		{name: "session not found", ctx: claimsContext("user-1", "session-1"), header: "Bearer " + token, storeErr: model.ErrNotFound, wantStatus: http.StatusUnauthorized},
		{name: "expired", ctx: claimsContext("user-1", "session-1"), header: "Bearer " + token, session: cloneSession(valid, func(s *model.AuthSessions) { s.ExpiresAt = time.Now().Add(-time.Minute) }), wantStatus: http.StatusUnauthorized},
		{name: "revoked", ctx: claimsContext("user-1", "session-1"), header: "Bearer " + token, session: cloneSession(valid, func(s *model.AuthSessions) { s.RevokedAt = sql.NullTime{Time: time.Now(), Valid: true} }), wantStatus: http.StatusUnauthorized},
		{name: "user mismatch", ctx: claimsContext("other", "session-1"), header: "Bearer " + token, session: valid, wantStatus: http.StatusUnauthorized},
		{name: "token mismatch", ctx: claimsContext("user-1", "session-1"), header: "Bearer other", session: valid, wantStatus: http.StatusUnauthorized},
		{name: "valid", ctx: claimsContext("user-1", "session-1"), header: "Bearer " + token, session: valid, wantStatus: http.StatusOK, wantNext: true, wantTouch: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			store := &fakeSessionStore{session: tt.session, err: tt.storeErr}
			mw := NewSessionAuthMiddleware(store)
			called := false
			req := httptest.NewRequest(http.MethodGet, "/", nil).WithContext(tt.ctx)
			if tt.header != "" {
				req.Header.Set("Authorization", tt.header)
			}
			rec := httptest.NewRecorder()

			mw.Handle(func(w http.ResponseWriter, r *http.Request) {
				called = true
				w.WriteHeader(http.StatusOK)
			})(rec, req)

			if rec.Code != tt.wantStatus {
				t.Fatalf("status = %d, want %d", rec.Code, tt.wantStatus)
			}
			if called != tt.wantNext {
				t.Fatalf("next called = %v, want %v", called, tt.wantNext)
			}
			if store.touched != tt.wantTouch {
				t.Fatalf("touched = %v, want %v", store.touched, tt.wantTouch)
			}
		})
	}
}

func claimsContext(userID, sessionID string) context.Context {
	ctx := context.WithValue(context.Background(), authsession.ClaimUserID, userID)
	return context.WithValue(ctx, authsession.ClaimSessionID, sessionID)
}

func cloneSession(src *model.AuthSessions, edit func(*model.AuthSessions)) *model.AuthSessions {
	dst := *src
	edit(&dst)
	return &dst
}
