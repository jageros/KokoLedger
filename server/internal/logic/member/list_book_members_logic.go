// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package member

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type ListBookMembersLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewListBookMembersLogic(ctx context.Context, svcCtx *svc.ServiceContext) *ListBookMembersLogic {
	return &ListBookMembersLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *ListBookMembersLogic) ListBookMembers(req *types.BookMembersReq) (resp *types.BookMemberListResp, err error) {
	// todo: add your logic here and delete this line

	return
}
