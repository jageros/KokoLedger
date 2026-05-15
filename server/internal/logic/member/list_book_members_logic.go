// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package member

import (
	"context"

	"koko/internal/logic/shared"
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
	if _, _, err := shared.RequireBookAccess(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	members, err := l.svcCtx.BookMembersModel.FindManyByBookID(l.ctx, req.BookId)
	if err != nil {
		return nil, err
	}
	data := make([]types.BookMember, 0, len(members))
	for _, member := range members {
		data = append(data, shared.MapMember(member))
	}

	return &types.BookMemberListResp{Data: data}, nil
}
