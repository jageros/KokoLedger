package model

import "github.com/zeromicro/go-zero/core/stores/sqlx"

var _ BooksModel = (*customBooksModel)(nil)

type (
	// BooksModel is an interface to be customized, add more methods here,
	// and implement the added methods in customBooksModel.
	BooksModel interface {
		booksModel
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
