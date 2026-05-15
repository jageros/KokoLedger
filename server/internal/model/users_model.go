package model

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
)

var _ UsersModel = (*customUsersModel)(nil)

type (
	// UsersModel is an interface to be customized, add more methods here,
	// and implement the added methods in customUsersModel.
	UsersModel interface {
		usersModel
		FindOneByEmail(ctx context.Context, email string) (*Users, error)
		FindOneByAccount(ctx context.Context, account string) (*Users, error)
		withSession(session sqlx.Session) UsersModel
	}

	customUsersModel struct {
		*defaultUsersModel
	}
)

// NewUsersModel returns a model for the database table.
func NewUsersModel(conn sqlx.SqlConn) UsersModel {
	return &customUsersModel{
		defaultUsersModel: newUsersModel(conn),
	}
}

func (m *customUsersModel) withSession(session sqlx.Session) UsersModel {
	return NewUsersModel(sqlx.NewSqlConnFromSession(session))
}

func (m *customUsersModel) FindOneByEmail(ctx context.Context, email string) (*Users, error) {
	var resp Users
	query := fmt.Sprintf("select %s from %s where lower(email) = lower($1) limit 1", usersRows, m.table)
	err := m.conn.QueryRowCtx(ctx, &resp, query, email)
	switch err {
	case nil:
		return &resp, nil
	case sqlx.ErrNotFound:
		return nil, ErrNotFound
	default:
		return nil, err
	}
}

func (m *customUsersModel) FindOneByAccount(ctx context.Context, account string) (*Users, error) {
	user, err := m.FindOneByEmail(ctx, account)
	if err == nil {
		return user, nil
	}
	if err != ErrNotFound {
		return nil, err
	}
	return m.FindOneByPhone(ctx, sql.NullString{String: account, Valid: true})
}
