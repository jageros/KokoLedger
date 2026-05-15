// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package book

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type GetBookLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewGetBookLogic(ctx context.Context, svcCtx *svc.ServiceContext) *GetBookLogic {
	return &GetBookLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *GetBookLogic) GetBook(req *types.BookPathReq) (resp *types.BookResp, err error) {
	// todo: add your logic here and delete this line

	return
}
