package model

import (
	"context"
	"fmt"
	"time"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
)

var _ AuthSessionsModel = (*customAuthSessionsModel)(nil)

type (
	// AuthSessionsModel is an interface to be customized, add more methods here,
	// and implement the added methods in customAuthSessionsModel.
	AuthSessionsModel interface {
		authSessionsModel
		Revoke(ctx context.Context, id string) error
		Touch(ctx context.Context, id string) error
		withSession(session sqlx.Session) AuthSessionsModel
	}

	customAuthSessionsModel struct {
		*defaultAuthSessionsModel
	}
)

// NewAuthSessionsModel returns a model for the database table.
func NewAuthSessionsModel(conn sqlx.SqlConn) AuthSessionsModel {
	return &customAuthSessionsModel{
		defaultAuthSessionsModel: newAuthSessionsModel(conn),
	}
}

func (m *customAuthSessionsModel) withSession(session sqlx.Session) AuthSessionsModel {
	return NewAuthSessionsModel(sqlx.NewSqlConnFromSession(session))
}

func (m *customAuthSessionsModel) Revoke(ctx context.Context, id string) error {
	query := fmt.Sprintf("update %s set revoked_at = now() where id = $1 and revoked_at is null", m.table)
	_, err := m.conn.ExecCtx(ctx, query, id)
	return err
}

func (m *customAuthSessionsModel) Touch(ctx context.Context, id string) error {
	query := fmt.Sprintf("update %s set last_used_at = $2 where id = $1", m.table)
	_, err := m.conn.ExecCtx(ctx, query, id, time.Now())
	return err
}
