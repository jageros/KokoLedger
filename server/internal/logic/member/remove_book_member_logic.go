// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package member

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type RemoveBookMemberLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewRemoveBookMemberLogic(ctx context.Context, svcCtx *svc.ServiceContext) *RemoveBookMemberLogic {
	return &RemoveBookMemberLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *RemoveBookMemberLogic) RemoveBookMember(req *types.RemoveMemberReq) (resp *types.EmptyResp, err error) {
	// todo: add your logic here and delete this line

	return
}
