// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package invite

import (
	"context"

	"koko/internal/logic/shared"
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
	if _, err := shared.RequireOwner(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	invites, err := l.svcCtx.BookInvitesModel.FindManyByBookID(l.ctx, req.BookId)
	if err != nil {
		return nil, err
	}
	data := make([]types.BookInvite, 0, len(invites))
	for _, invite := range invites {
		data = append(data, shared.MapInvite(invite))
	}

	return &types.BookInviteListResp{Data: data}, nil
}
