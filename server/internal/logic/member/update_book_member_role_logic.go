// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package member

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type UpdateBookMemberRoleLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewUpdateBookMemberRoleLogic(ctx context.Context, svcCtx *svc.ServiceContext) *UpdateBookMemberRoleLogic {
	return &UpdateBookMemberRoleLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *UpdateBookMemberRoleLogic) UpdateBookMemberRole(req *types.UpdateMemberRoleReq) (resp *types.BookMemberResp, err error) {
	// todo: add your logic here and delete this line

	return
}
