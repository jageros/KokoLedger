package model

import "github.com/zeromicro/go-zero/core/stores/sqlx"

var _ LedgerTransactionsModel = (*customLedgerTransactionsModel)(nil)

type (
	// LedgerTransactionsModel is an interface to be customized, add more methods here,
	// and implement the added methods in customLedgerTransactionsModel.
	LedgerTransactionsModel interface {
		ledgerTransactionsModel
		withSession(session sqlx.Session) LedgerTransactionsModel
	}

	customLedgerTransactionsModel struct {
		*defaultLedgerTransactionsModel
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
