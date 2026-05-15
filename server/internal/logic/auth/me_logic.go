// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package auth

import (
	"context"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type MeLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewMeLogic(ctx context.Context, svcCtx *svc.ServiceContext) *MeLogic {
	return &MeLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *MeLogic) Me() (resp *types.UserResp, err error) {
	userID, err := shared.CurrentUserID(l.ctx)
	if err != nil {
		return nil, err
	}
	user, err := l.svcCtx.UsersModel.FindOne(l.ctx, userID)
	if err != nil {
		return nil, err
	}

	return &types.UserResp{Data: shared.MapUser(user)}, nil
}
