// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package auth

import (
	"context"
	"errors"

	"koko/internal/logic/shared"
	"koko/internal/model"
	"koko/internal/pkg/authsession"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/google/uuid"
	"github.com/zeromicro/go-zero/core/logx"
	"golang.org/x/crypto/bcrypt"
)

type LoginLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewLoginLogic(ctx context.Context, svcCtx *svc.ServiceContext) *LoginLogic {
	return &LoginLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *LoginLogic) Login(req *types.LoginReq) (resp *types.LoginResp, err error) {
	account := utils.Clean(req.Account)
	if account == "" || req.Password == "" {
		return nil, errors.New("account and password are required")
	}
	user, err := l.svcCtx.UsersModel.FindOneByAccount(l.ctx, account)
	if err != nil {
		return nil, errors.New("invalid account or password")
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, errors.New("invalid account or password")
	}
	sessionID := uuid.NewString()
	token, expiresAt, err := authsession.BuildToken(l.svcCtx.Config.Auth.AccessSecret, l.svcCtx.Config.Auth.AccessExpire, user.Id, sessionID)
	if err != nil {
		return nil, err
	}
	session := &model.AuthSessions{
		Id:        sessionID,
		UserId:    user.Id,
		TokenHash: authsession.TokenHash(token),
		ExpiresAt: expiresAt,
	}
	if _, err := l.svcCtx.AuthSessionsModel.Insert(l.ctx, session); err != nil {
		return nil, err
	}

	return &types.LoginResp{Token: token, User: shared.MapUser(user)}, nil
}
