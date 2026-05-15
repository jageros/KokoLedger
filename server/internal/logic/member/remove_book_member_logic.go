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
	book, err := shared.RequireOwner(l.ctx, l.svcCtx, req.BookId)
	if err != nil {
		return nil, err
	}
	member, err := l.svcCtx.BookMembersModel.FindOneByBookIDAndMemberID(l.ctx, req.BookId, req.MemberId)
	if err != nil {
		return nil, shared.NormalizeModelErr(err)
	}
	if member.UserId == book.OwnerId {
		return nil, shared.ErrForbidden
	}
	if err := l.svcCtx.BookMembersModel.Delete(l.ctx, member.Id); err != nil {
		return nil, err
	}

	return &types.EmptyResp{}, nil
}
