// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package middleware

import (
	"context"
	"net/http"
	"strings"
	"time"

	"koko/internal/model"
	"koko/internal/pkg/authsession"
)

type SessionAuthMiddleware struct {
	sessions sessionStore
}

type sessionStore interface {
	FindOne(rctx context.Context, id string) (*model.AuthSessions, error)
	Touch(rctx context.Context, id string) error
}

func NewSessionAuthMiddleware(sessions sessionStore) *SessionAuthMiddleware {
	return &SessionAuthMiddleware{sessions: sessions}
}

func (m *SessionAuthMiddleware) Handle(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		userID, sessionID, err := authsession.ClaimsFromContext(r.Context())
		if err != nil {
			unauthorized(w)
			return
		}

		session, err := m.sessions.FindOne(r.Context(), sessionID)
		if err != nil {
			unauthorized(w)
			return
		}
		if session.UserId != userID || session.RevokedAt.Valid || !session.ExpiresAt.After(time.Now()) {
			unauthorized(w)
			return
		}
		token := bearerToken(r.Header.Get("Authorization"))
		if token == "" || session.TokenHash != authsession.TokenHash(token) {
			unauthorized(w)
			return
		}

		_ = m.sessions.Touch(r.Context(), sessionID)
		next(w, r)
	}
}

func unauthorized(w http.ResponseWriter) {
	http.Error(w, "unauthorized", http.StatusUnauthorized)
}

func bearerToken(header string) string {
	const prefix = "Bearer "
	if len(header) < len(prefix) || !strings.EqualFold(header[:len(prefix)], prefix) {
		return ""
	}
	return strings.TrimSpace(header[len(prefix):])
}
