// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package book

import (
	"context"

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
	// todo: add your logic here and delete this line

	return
}
