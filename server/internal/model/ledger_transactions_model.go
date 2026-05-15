package model

import (
	"context"
	"fmt"
	"time"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
)

var _ LedgerTransactionsModel = (*customLedgerTransactionsModel)(nil)

type (
	// LedgerTransactionsModel is an interface to be customized, add more methods here,
	// and implement the added methods in customLedgerTransactionsModel.
	LedgerTransactionsModel interface {
		ledgerTransactionsModel
		FindOneByBookID(ctx context.Context, bookID, id string) (*LedgerTransactions, error)
		FindManyByBook(ctx context.Context, bookID string, from, to *time.Time) ([]*LedgerTransactions, error)
		SoftDelete(ctx context.Context, bookID, id string) error
		Summary(ctx context.Context, bookID string, from, to time.Time) (TransactionSummary, error)
		Trend(ctx context.Context, bookID string, from, to time.Time) ([]TrendSummary, error)
		CategoryRatios(ctx context.Context, bookID, tp, level string, from, to time.Time) ([]CategoryRatioSummary, error)
		withSession(session sqlx.Session) LedgerTransactionsModel
	}

	customLedgerTransactionsModel struct {
		*defaultLedgerTransactionsModel
	}

	TransactionSummary struct {
		IncomeMinor  int64  `db:"income_minor"`
		ExpenseMinor int64  `db:"expense_minor"`
		CurrencyCode string `db:"currency_code"`
	}

	TrendSummary struct {
		Date         time.Time `db:"date"`
		IncomeMinor  int64     `db:"income_minor"`
		ExpenseMinor int64     `db:"expense_minor"`
	}

	CategoryRatioSummary struct {
		CategoryId   string `db:"category_id"`
		CategoryName string `db:"category_name"`
		AmountMinor  int64  `db:"amount_minor"`
	}
)

// NewLedgerTransactionsModel returns a model for the database table.
func NewLedgerTransactionsModel(conn sqlx.SqlConn) LedgerTransactionsModel {
	return &customLedgerTransactionsModel{
		defaultLedgerTransactionsModel: newLedgerTransactionsModel(conn),
	}
}

func (m *customLedgerTransactionsModel) withSession(session sqlx.Session) LedgerTransactionsModel {
	return NewLedgerTransactionsModel(sqlx.NewSqlConnFromSession(session))
}

func (m *customLedgerTransactionsModel) FindOneByBookID(ctx context.Context, bookID, id string) (*LedgerTransactions, error) {
	query := fmt.Sprintf("select %s from %s where book_id = $1 and id = $2 and deleted_at is null limit 1", ledgerTransactionsRows, m.table)
	var resp LedgerTransactions
	err := m.conn.QueryRowCtx(ctx, &resp, query, bookID, id)
	switch err {
	case nil:
		return &resp, nil
	case sqlx.ErrNotFound:
		return nil, ErrNotFound
	default:
		return nil, err
	}
}

func (m *customLedgerTransactionsModel) FindManyByBook(ctx context.Context, bookID string, from, to *time.Time) ([]*LedgerTransactions, error) {
	query := fmt.Sprintf("select %s from %s where book_id = $1 and deleted_at is null", ledgerTransactionsRows, m.table)
	args := []any{bookID}
	if from != nil {
		query += fmt.Sprintf(" and occurred_at >= $%d", len(args)+1)
		args = append(args, *from)
	}
	if to != nil {
		query += fmt.Sprintf(" and occurred_at < $%d", len(args)+1)
		args = append(args, *to)
	}
	query += " order by occurred_at desc, created_at desc"
	var resp []*LedgerTransactions
	err := m.conn.QueryRowsCtx(ctx, &resp, query, args...)
	return resp, err
}

func (m *customLedgerTransactionsModel) SoftDelete(ctx context.Context, bookID, id string) error {
	query := fmt.Sprintf("update %s set deleted_at = $3 where book_id = $1 and id = $2 and deleted_at is null", m.table)
	_, err := m.conn.ExecCtx(ctx, query, bookID, id, time.Now())
	return err
}

func (m *customLedgerTransactionsModel) Summary(ctx context.Context, bookID string, from, to time.Time) (TransactionSummary, error) {
	query := fmt.Sprintf(`select
coalesce(sum(amount_minor) filter (where type = 'income'), 0) as income_minor,
coalesce(sum(amount_minor) filter (where type = 'expense'), 0) as expense_minor,
coalesce(max(currency_code), 'CNY') as currency_code
from %s where book_id = $1 and deleted_at is null`, m.table)
	args := []any{bookID}
	query, args = appendRange(query, args, from, to)
	var resp TransactionSummary
	err := m.conn.QueryRowCtx(ctx, &resp, query, args...)
	return resp, err
}

func (m *customLedgerTransactionsModel) Trend(ctx context.Context, bookID string, from, to time.Time) ([]TrendSummary, error) {
	query := fmt.Sprintf(`select date_trunc('day', occurred_at)::date as date,
coalesce(sum(amount_minor) filter (where type = 'income'), 0) as income_minor,
coalesce(sum(amount_minor) filter (where type = 'expense'), 0) as expense_minor
from %s where book_id = $1 and deleted_at is null`, m.table)
	args := []any{bookID}
	query, args = appendRange(query, args, from, to)
	query += " group by date order by date asc"
	var resp []TrendSummary
	err := m.conn.QueryRowsCtx(ctx, &resp, query, args...)
	return resp, err
}

func (m *customLedgerTransactionsModel) CategoryRatios(ctx context.Context, bookID, tp, level string, from, to time.Time) ([]CategoryRatioSummary, error) {
	categoryColumn := "category_level1_id"
	if level == "level2" {
		categoryColumn = "category_level2_id"
	}
	query := fmt.Sprintf(`select c.id as category_id, c.name as category_name, coalesce(sum(t.amount_minor), 0) as amount_minor
from %s t
join "public"."transaction_categories" c on c.id = t.%s
where t.book_id = $1 and t.type = $2 and t.deleted_at is null`, m.table, categoryColumn)
	args := []any{bookID, tp}
	query, args = appendRange(query, args, from, to)
	query += " group by c.id, c.name order by amount_minor desc, c.name asc"
	var resp []CategoryRatioSummary
	err := m.conn.QueryRowsCtx(ctx, &resp, query, args...)
	return resp, err
}

func appendRange(query string, args []any, from, to time.Time) (string, []any) {
	if !from.IsZero() {
		query += fmt.Sprintf(" and occurred_at >= $%d", len(args)+1)
		args = append(args, from)
	}
	if !to.IsZero() {
		query += fmt.Sprintf(" and occurred_at < $%d", len(args)+1)
		args = append(args, to)
	}
	return query, args
}
