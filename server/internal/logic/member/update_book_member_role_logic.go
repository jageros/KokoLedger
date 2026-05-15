// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package member

import (
	"context"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

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
	book, err := shared.RequireOwner(l.ctx, l.svcCtx, req.BookId)
	if err != nil {
		return nil, err
	}
	if err := utils.ValidateRole(req.Role); err != nil {
		return nil, err
	}
	member, err := l.svcCtx.BookMembersModel.FindOneByBookIDAndMemberID(l.ctx, req.BookId, req.MemberId)
	if err != nil {
		return nil, shared.NormalizeModelErr(err)
	}
	if member.UserId == book.OwnerId {
		return nil, shared.ErrForbidden
	}
	member.Role = req.Role
	if err := l.svcCtx.BookMembersModel.Update(l.ctx, member); err != nil {
		return nil, err
	}

	return &types.BookMemberResp{Data: shared.MapMember(member)}, nil
}
