package model

import "github.com/zeromicro/go-zero/core/stores/sqlx"

var _ BookInvitesModel = (*customBookInvitesModel)(nil)

type (
	// BookInvitesModel is an interface to be customized, add more methods here,
	// and implement the added methods in customBookInvitesModel.
	BookInvitesModel interface {
		bookInvitesModel
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
