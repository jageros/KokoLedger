package model

import (
	"context"
	"fmt"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
)

var _ BookInvitesModel = (*customBookInvitesModel)(nil)

type (
	// BookInvitesModel is an interface to be customized, add more methods here,
	// and implement the added methods in customBookInvitesModel.
	BookInvitesModel interface {
		bookInvitesModel
		FindManyByBookID(ctx context.Context, bookID string) ([]*BookInvites, error)
		FindOneByBookIDAndInviteID(ctx context.Context, bookID, inviteID string) (*BookInvites, error)
		Revoke(ctx context.Context, bookID, inviteID string) error
		withSession(session sqlx.Session) BookInvitesModel
	}

	customBookInvitesModel struct {
		*defaultBookInvitesModel
	}
)

// NewBookInvitesModel returns a model for the database table.
func NewBookInvitesModel(conn sqlx.SqlConn) BookInvitesModel {
	return &customBookInvitesModel{
		defaultBookInvitesModel: newBookInvitesModel(conn),
	}
}

func (m *customBookInvitesModel) withSession(session sqlx.Session) BookInvitesModel {
	return NewBookInvitesModel(sqlx.NewSqlConnFromSession(session))
}

func (m *customBookInvitesModel) FindManyByBookID(ctx context.Context, bookID string) ([]*BookInvites, error) {
	query := fmt.Sprintf("select %s from %s where book_id = $1 order by created_at desc", bookInvitesRows, m.table)
	var resp []*BookInvites
	err := m.conn.QueryRowsCtx(ctx, &resp, query, bookID)
	return resp, err
}

func (m *customBookInvitesModel) FindOneByBookIDAndInviteID(ctx context.Context, bookID, inviteID string) (*BookInvites, error) {
	query := fmt.Sprintf("select %s from %s where book_id = $1 and id = $2 limit 1", bookInvitesRows, m.table)
	var resp BookInvites
	err := m.conn.QueryRowCtx(ctx, &resp, query, bookID, inviteID)
	switch err {
	case nil:
		return &resp, nil
	case sqlx.ErrNotFound:
		return nil, ErrNotFound
	default:
		return nil, err
	}
}

func (m *customBookInvitesModel) Revoke(ctx context.Context, bookID, inviteID string) error {
	query := fmt.Sprintf("update %s set status = 'revoked' where book_id = $1 and id = $2 and status = 'pending'", m.table)
	_, err := m.conn.ExecCtx(ctx, query, bookID, inviteID)
	return err
}
