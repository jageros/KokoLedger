package model

import (
	"context"
	"fmt"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
)

var _ BookMembersModel = (*customBookMembersModel)(nil)

type (
	// BookMembersModel is an interface to be customized, add more methods here,
	// and implement the added methods in customBookMembersModel.
	BookMembersModel interface {
		bookMembersModel
		FindManyByBookID(ctx context.Context, bookID string) ([]*BookMembers, error)
		FindOneByBookIDAndMemberID(ctx context.Context, bookID, memberID string) (*BookMembers, error)
		withSession(session sqlx.Session) BookMembersModel
	}

	customBookMembersModel struct {
		*defaultBookMembersModel
	}
)

// NewBookMembersModel returns a model for the database table.
func NewBookMembersModel(conn sqlx.SqlConn) BookMembersModel {
	return &customBookMembersModel{
		defaultBookMembersModel: newBookMembersModel(conn),
	}
}

func (m *customBookMembersModel) withSession(session sqlx.Session) BookMembersModel {
	return NewBookMembersModel(sqlx.NewSqlConnFromSession(session))
}

func (m *customBookMembersModel) FindManyByBookID(ctx context.Context, bookID string) ([]*BookMembers, error) {
	query := fmt.Sprintf("select %s from %s where book_id = $1 order by joined_at asc", bookMembersRows, m.table)
	var resp []*BookMembers
	err := m.conn.QueryRowsCtx(ctx, &resp, query, bookID)
	return resp, err
}

func (m *customBookMembersModel) FindOneByBookIDAndMemberID(ctx context.Context, bookID, memberID string) (*BookMembers, error) {
	query := fmt.Sprintf("select %s from %s where book_id = $1 and id = $2 limit 1", bookMembersRows, m.table)
	var resp BookMembers
	err := m.conn.QueryRowCtx(ctx, &resp, query, bookID, memberID)
	switch err {
	case nil:
		return &resp, nil
	case sqlx.ErrNotFound:
		return nil, ErrNotFound
	default:
		return nil, err
	}
}
