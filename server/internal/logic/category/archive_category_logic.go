// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package category

import (
	"context"

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
	// todo: add your logic here and delete this line

	return
}
