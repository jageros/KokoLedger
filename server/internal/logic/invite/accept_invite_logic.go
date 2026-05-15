// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package invite

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type AcceptInviteLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewAcceptInviteLogic(ctx context.Context, svcCtx *svc.ServiceContext) *AcceptInviteLogic {
	return &AcceptInviteLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *AcceptInviteLogic) AcceptInvite(req *types.AcceptInviteReq) (resp *types.BookMemberResp, err error) {
	// todo: add your logic here and delete this line

	return
}
