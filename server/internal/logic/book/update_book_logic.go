// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package book

import (
	"context"
	"errors"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/zeromicro/go-zero/core/logx"
)

type UpdateBookLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewUpdateBookLogic(ctx context.Context, svcCtx *svc.ServiceContext) *UpdateBookLogic {
	return &UpdateBookLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *UpdateBookLogic) UpdateBook(req *types.UpdateBookReq) (resp *types.BookResp, err error) {
	book, err := shared.RequireOwner(l.ctx, l.svcCtx, req.BookId)
	if err != nil {
		return nil, err
	}
	name := utils.Clean(req.Name)
	if name == "" {
		return nil, errors.New("name is required")
	}
	currency := utils.NormalizeCurrency(req.DefaultCurrencyCode)
	if err := utils.ValidateCurrency(currency); err != nil {
		return nil, err
	}
	book.Name = name
	book.Note = shared.NullString(req.Note)
	book.DefaultCurrencyCode = currency
	if err := l.svcCtx.BooksModel.Update(l.ctx, book); err != nil {
		return nil, err
	}
	book, err = l.svcCtx.BooksModel.FindOne(l.ctx, book.Id)
	if err != nil {
		return nil, err
	}

	return &types.BookResp{Data: shared.MapBook(book)}, nil
}
