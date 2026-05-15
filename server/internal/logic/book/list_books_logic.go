// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package book

import (
	"context"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type ListBooksLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewListBooksLogic(ctx context.Context, svcCtx *svc.ServiceContext) *ListBooksLogic {
	return &ListBooksLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *ListBooksLogic) ListBooks() (resp *types.BookListResp, err error) {
	userID, err := shared.CurrentUserID(l.ctx)
	if err != nil {
		return nil, err
	}
	books, err := l.svcCtx.BooksModel.FindAccessible(l.ctx, userID)
	if err != nil {
		return nil, err
	}
	data := make([]types.Book, 0, len(books))
	for _, book := range books {
		data = append(data, shared.MapBook(book))
	}

	return &types.BookListResp{Data: data}, nil
}
