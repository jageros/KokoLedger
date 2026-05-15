package model

import (
	"context"
	"fmt"
	"time"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
)

var _ BooksModel = (*customBooksModel)(nil)

type (
	// BooksModel is an interface to be customized, add more methods here,
	// and implement the added methods in customBooksModel.
	BooksModel interface {
		booksModel
		FindAccessible(ctx context.Context, userID string) ([]*Books, error)
		Archive(ctx context.Context, id string) error
		withSession(session sqlx.Session) BooksModel
	}

	customBooksModel struct {
		*defaultBooksModel
	}
)

// NewBooksModel returns a model for the database table.
func NewBooksModel(conn sqlx.SqlConn) BooksModel {
	return &customBooksModel{
		defaultBooksModel: newBooksModel(conn),
	}
}

func (m *customBooksModel) withSession(session sqlx.Session) BooksModel {
	return NewBooksModel(sqlx.NewSqlConnFromSession(session))
}

func (m *customBooksModel) FindAccessible(ctx context.Context, userID string) ([]*Books, error) {
	query := fmt.Sprintf(`select distinct b.id, b.name, b.note, b.default_currency_code, b.owner_id, b.created_at, b.updated_at, b.archived_at
from %s b
left join "public"."book_members" bm on bm.book_id = b.id and bm.user_id = $1
where b.archived_at is null and (b.owner_id = $1 or bm.id is not null)
order by b.updated_at desc`, m.table)
	var resp []*Books
	err := m.conn.QueryRowsCtx(ctx, &resp, query, userID)
	return resp, err
}

func (m *customBooksModel) Archive(ctx context.Context, id string) error {
	query := fmt.Sprintf("update %s set archived_at = $2 where id = $1", m.table)
	_, err := m.conn.ExecCtx(ctx, query, id, time.Now())
	return err
}
