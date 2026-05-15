package model

import "github.com/zeromicro/go-zero/core/stores/sqlx"

var _ TransactionCategoriesModel = (*customTransactionCategoriesModel)(nil)

type (
	// TransactionCategoriesModel is an interface to be customized, add more methods here,
	// and implement the added methods in customTransactionCategoriesModel.
	TransactionCategoriesModel interface {
		transactionCategoriesModel
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
