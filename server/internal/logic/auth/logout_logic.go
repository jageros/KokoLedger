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

type LogoutLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewLogoutLogic(ctx context.Context, svcCtx *svc.ServiceContext) *LogoutLogic {
	return &LogoutLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *LogoutLogic) Logout() (resp *types.EmptyResp, err error) {
	sessionID, err := shared.CurrentSessionID(l.ctx)
	if err != nil {
		return nil, err
	}
	if err := l.svcCtx.AuthSessionsModel.Revoke(l.ctx, sessionID); err != nil {
		return nil, err
	}

	return &types.EmptyResp{}, nil
}
