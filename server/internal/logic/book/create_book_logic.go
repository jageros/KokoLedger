// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package book

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type CreateBookLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewCreateBookLogic(ctx context.Context, svcCtx *svc.ServiceContext) *CreateBookLogic {
	return &CreateBookLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *CreateBookLogic) CreateBook(req *types.CreateBookReq) (resp *types.BookResp, err error) {
	// todo: add your logic here and delete this line

	return
}
