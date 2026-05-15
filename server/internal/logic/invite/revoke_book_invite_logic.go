// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package invite

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type RevokeBookInviteLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewRevokeBookInviteLogic(ctx context.Context, svcCtx *svc.ServiceContext) *RevokeBookInviteLogic {
	return &RevokeBookInviteLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *RevokeBookInviteLogic) RevokeBookInvite(req *types.RevokeInviteReq) (resp *types.EmptyResp, err error) {
	// todo: add your logic here and delete this line

	return
}
