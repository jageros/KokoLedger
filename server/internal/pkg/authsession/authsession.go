package authsession

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v4"
)

const (
	ClaimUserID    = "userId"
	ClaimSessionID = "sessionId"
)

var ErrMissingClaims = errors.New("missing auth claims")

func BuildToken(secret string, expireSeconds int64, userID, sessionID string) (string, time.Time, error) {
	now := time.Now()
	expiresAt := now.Add(time.Duration(expireSeconds) * time.Second)
	claims := jwt.MapClaims{
		"exp":          expiresAt.Unix(),
		"iat":          now.Unix(),
		ClaimUserID:    userID,
		ClaimSessionID: sessionID,
	}
	token, err := jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString([]byte(secret))
	if err != nil {
		return "", time.Time{}, err
	}
	return token, expiresAt, nil
}

func TokenHash(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}

func UserIDFromContext(ctx context.Context) (string, error) {
	return stringClaim(ctx, ClaimUserID)
}

func SessionIDFromContext(ctx context.Context) (string, error) {
	return stringClaim(ctx, ClaimSessionID)
}

func ClaimsFromContext(ctx context.Context) (userID, sessionID string, err error) {
	userID, err = UserIDFromContext(ctx)
	if err != nil {
		return "", "", err
	}
	sessionID, err = SessionIDFromContext(ctx)
	if err != nil {
		return "", "", err
	}
	return userID, sessionID, nil
}

func stringClaim(ctx context.Context, key string) (string, error) {
	raw := ctx.Value(key)
	switch value := raw.(type) {
	case string:
		if value == "" {
			return "", ErrMissingClaims
		}
		return value, nil
	case fmt.Stringer:
		claimValue := value.String()
		if claimValue == "" {
			return "", ErrMissingClaims
		}
		return claimValue, nil
	default:
		return "", ErrMissingClaims
	}
}
