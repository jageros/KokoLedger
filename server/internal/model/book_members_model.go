package model

import "github.com/zeromicro/go-zero/core/stores/sqlx"

var _ BookMembersModel = (*customBookMembersModel)(nil)

type (
	// BookMembersModel is an interface to be customized, add more methods here,
	// and implement the added methods in customBookMembersModel.
	BookMembersModel interface {
		bookMembersModel
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
