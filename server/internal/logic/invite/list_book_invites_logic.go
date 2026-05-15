// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package invite

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type ListBookInvitesLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewListBookInvitesLogic(ctx context.Context, svcCtx *svc.ServiceContext) *ListBookInvitesLogic {
	return &ListBookInvitesLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *ListBookInvitesLogic) ListBookInvites(req *types.ListInvitesReq) (resp *types.BookInviteListResp, err error) {
	// todo: add your logic here and delete this line

	return
}
