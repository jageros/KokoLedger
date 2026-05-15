// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package svc

import (
	"koko/internal/config"
	"koko/internal/middleware"
	"koko/internal/model"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
	"github.com/zeromicro/go-zero/rest"
)

type ServiceContext struct {
	Config                config.Config
	Conn                  sqlx.SqlConn
	UsersModel            model.UsersModel
	AuthSessionsModel     model.AuthSessionsModel
	BooksModel            model.BooksModel
	BookMembersModel      model.BookMembersModel
	BookInvitesModel      model.BookInvitesModel
	TransactionCategories model.TransactionCategoriesModel
	LedgerTransactions    model.LedgerTransactionsModel
	SessionAuth           rest.Middleware
}

func NewServiceContext(c config.Config) *ServiceContext {
	conn := c.Postgres.Conn()
	return &ServiceContext{
		Config:                c,
		Conn:                  conn,
		UsersModel:            model.NewUsersModel(conn),
		AuthSessionsModel:     model.NewAuthSessionsModel(conn),
		BooksModel:            model.NewBooksModel(conn),
		BookMembersModel:      model.NewBookMembersModel(conn),
		BookInvitesModel:      model.NewBookInvitesModel(conn),
		TransactionCategories: model.NewTransactionCategoriesModel(conn),
		LedgerTransactions:    model.NewLedgerTransactionsModel(conn),
		SessionAuth:           middleware.NewSessionAuthMiddleware(model.NewAuthSessionsModel(conn)).Handle,
	}
}
