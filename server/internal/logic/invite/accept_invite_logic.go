// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package invite

import (
	"context"
	"errors"
	"time"

	"koko/internal/logic/shared"
	"koko/internal/model"
	"koko/internal/svc"
	"koko/internal/types"

	"github.com/google/uuid"
	"github.com/zeromicro/go-zero/core/logx"
	"github.com/zeromicro/go-zero/core/stores/sqlx"
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
	userID, err := shared.CurrentUserID(l.ctx)
	if err != nil {
		return nil, err
	}
	invite, err := l.svcCtx.BookInvitesModel.FindOneByInviteCode(l.ctx, req.InviteCode)
	if err != nil {
		return nil, shared.NormalizeModelErr(err)
	}
	if invite.Status != "pending" {
		return nil, errors.New("invite is not pending")
	}
	if !invite.ExpiresAt.After(time.Now()) {
		invite.Status = "expired"
		_ = l.svcCtx.BookInvitesModel.Update(l.ctx, invite)
		return nil, errors.New("invite expired")
	}
	if member, err := l.svcCtx.BookMembersModel.FindOneByBookIdUserId(l.ctx, invite.BookId, userID); err == nil {
		return &types.BookMemberResp{Data: shared.MapMember(member)}, nil
	} else if err != model.ErrNotFound {
		return nil, err
	}

	memberID := uuid.NewString()
	err = l.svcCtx.Conn.TransactCtx(l.ctx, func(ctx context.Context, session sqlx.Session) error {
		if _, err := session.ExecCtx(ctx, `insert into book_members (id, book_id, user_id, role, joined_at) values ($1, $2, $3, $4, now())`,
			memberID, invite.BookId, userID, invite.Role); err != nil {
			return err
		}
		_, err := session.ExecCtx(ctx, `update book_invites set status = 'joined', accepted_at = now() where id = $1`, invite.Id)
		return err
	})
	if err != nil {
		return nil, err
	}
	member, err := l.svcCtx.BookMembersModel.FindOne(l.ctx, memberID)
	if err != nil {
		return nil, err
	}

	return &types.BookMemberResp{Data: shared.MapMember(member)}, nil
}
