package model

import (
	"context"
	"fmt"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
)

var _ TransactionCategoriesModel = (*customTransactionCategoriesModel)(nil)

type (
	// TransactionCategoriesModel is an interface to be customized, add more methods here,
	// and implement the added methods in customTransactionCategoriesModel.
	TransactionCategoriesModel interface {
		transactionCategoriesModel
		FindManyByBook(ctx context.Context, bookID, tp string, includeArchived bool) ([]*TransactionCategories, error)
		NextSortOrder(ctx context.Context, bookID, tp, level, parentID string) (int, error)
		Archive(ctx context.Context, bookID, id string) error
		withSession(session sqlx.Session) TransactionCategoriesModel
	}

	customTransactionCategoriesModel struct {
		*defaultTransactionCategoriesModel
	}
)

// NewTransactionCategoriesModel returns a model for the database table.
func NewTransactionCategoriesModel(conn sqlx.SqlConn) TransactionCategoriesModel {
	return &customTransactionCategoriesModel{
		defaultTransactionCategoriesModel: newTransactionCategoriesModel(conn),
	}
}

func (m *customTransactionCategoriesModel) withSession(session sqlx.Session) TransactionCategoriesModel {
	return NewTransactionCategoriesModel(sqlx.NewSqlConnFromSession(session))
}

func (m *customTransactionCategoriesModel) FindManyByBook(ctx context.Context, bookID, tp string, includeArchived bool) ([]*TransactionCategories, error) {
	query := fmt.Sprintf("select %s from %s where book_id = $1", transactionCategoriesRows, m.table)
	args := []any{bookID}
	if tp != "" {
		query += " and type = $2"
		args = append(args, tp)
	}
	if !includeArchived {
		query += fmt.Sprintf(" and is_archived = false")
	}
	query += " order by type asc, level asc, sort_order asc, created_at asc"
	var resp []*TransactionCategories
	err := m.conn.QueryRowsCtx(ctx, &resp, query, args...)
	return resp, err
}

func (m *customTransactionCategoriesModel) NextSortOrder(ctx context.Context, bookID, tp, level, parentID string) (int, error) {
	query := fmt.Sprintf("select coalesce(max(sort_order), 0) + 1 from %s where book_id = $1 and type = $2 and level = $3", m.table)
	args := []any{bookID, tp, level}
	if parentID == "" {
		query += " and parent_id is null"
	} else {
		query += " and parent_id = $4"
		args = append(args, parentID)
	}
	var next int
	err := m.conn.QueryRowCtx(ctx, &next, query, args...)
	return next, err
}

func (m *customTransactionCategoriesModel) Archive(ctx context.Context, bookID, id string) error {
	query := fmt.Sprintf("update %s set is_archived = true where book_id = $1 and id = $2", m.table)
	_, err := m.conn.ExecCtx(ctx, query, bookID, id)
	return err
}
