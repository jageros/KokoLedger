// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package invite

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"time"

	"koko/internal/logic/shared"
	"koko/internal/model"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/google/uuid"
	"github.com/zeromicro/go-zero/core/logx"
)

type CreateBookInviteLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewCreateBookInviteLogic(ctx context.Context, svcCtx *svc.ServiceContext) *CreateBookInviteLogic {
	return &CreateBookInviteLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *CreateBookInviteLogic) CreateBookInvite(req *types.CreateInviteReq) (resp *types.BookInviteResp, err error) {
	if _, err := shared.RequireOwner(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	if err := utils.ValidateRole(req.Role); err != nil {
		return nil, err
	}
	userID, err := shared.CurrentUserID(l.ctx)
	if err != nil {
		return nil, err
	}
	invite := &model.BookInvites{
		Id:              uuid.NewString(),
		BookId:          req.BookId,
		InviteCode:      inviteCode(),
		InvitedByUserId: userID,
		Role:            req.Role,
		Status:          "pending",
		ExpiresAt:       time.Now().Add(7 * 24 * time.Hour),
	}
	if _, err := l.svcCtx.BookInvitesModel.Insert(l.ctx, invite); err != nil {
		return nil, err
	}
	invite, err = l.svcCtx.BookInvitesModel.FindOne(l.ctx, invite.Id)
	if err != nil {
		return nil, err
	}

	return &types.BookInviteResp{Data: shared.MapInvite(invite)}, nil
}

func inviteCode() string {
	var b [12]byte
	if _, err := rand.Read(b[:]); err != nil {
		return uuid.NewString()
	}
	return base64.RawURLEncoding.EncodeToString(b[:])
}
