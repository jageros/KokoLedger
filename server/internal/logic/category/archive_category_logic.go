// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package category

import (
	"context"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type ArchiveCategoryLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewArchiveCategoryLogic(ctx context.Context, svcCtx *svc.ServiceContext) *ArchiveCategoryLogic {
	return &ArchiveCategoryLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *ArchiveCategoryLogic) ArchiveCategory(req *types.CategoryPathReq) (resp *types.EmptyResp, err error) {
	if _, err := shared.RequireWritable(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	if err := l.svcCtx.TransactionCategories.Archive(l.ctx, req.BookId, req.CategoryId); err != nil {
		return nil, err
	}

	return &types.EmptyResp{}, nil
}
