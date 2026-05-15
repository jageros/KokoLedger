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

type ArchiveBookLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewArchiveBookLogic(ctx context.Context, svcCtx *svc.ServiceContext) *ArchiveBookLogic {
	return &ArchiveBookLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *ArchiveBookLogic) ArchiveBook(req *types.BookPathReq) (resp *types.EmptyResp, err error) {
	if _, err := shared.RequireOwner(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	if err := l.svcCtx.BooksModel.Archive(l.ctx, req.BookId); err != nil {
		return nil, err
	}

	return &types.EmptyResp{}, nil
}
