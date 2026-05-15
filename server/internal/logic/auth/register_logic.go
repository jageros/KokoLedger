// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package auth

import (
	"context"
	"errors"

	"koko/internal/logic/shared"
	"koko/internal/model"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/google/uuid"
	"github.com/zeromicro/go-zero/core/logx"
	"golang.org/x/crypto/bcrypt"
)

type RegisterLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewRegisterLogic(ctx context.Context, svcCtx *svc.ServiceContext) *RegisterLogic {
	return &RegisterLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *RegisterLogic) Register(req *types.RegisterReq) (resp *types.UserResp, err error) {
	email := utils.NormalizeEmail(req.Email)
	phone := utils.Clean(req.Phone)
	nickname := utils.Clean(req.Nickname)
	if nickname == "" {
		return nil, errors.New("nickname is required")
	}
	if email == "" && phone == "" {
		return nil, errors.New("email or phone is required")
	}
	if err := utils.ValidateEmail(email); err != nil {
		return nil, err
	}
	if err := utils.ValidatePassword(req.Password); err != nil {
		return nil, err
	}
	if email != "" {
		if _, err := l.svcCtx.UsersModel.FindOneByEmail(l.ctx, email); err == nil {
			return nil, errors.New("email already exists")
		} else if err != model.ErrNotFound {
			return nil, err
		}
	}
	if phone != "" {
		if _, err := l.svcCtx.UsersModel.FindOneByPhone(l.ctx, utils.NullString(phone)); err == nil {
			return nil, errors.New("phone already exists")
		} else if err != model.ErrNotFound {
			return nil, err
		}
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}
	user := &model.Users{
		Id:           uuid.NewString(),
		Nickname:     nickname,
		Email:        utils.NullString(email),
		Phone:        utils.NullString(phone),
		PasswordHash: string(passwordHash),
	}
	if _, err := l.svcCtx.UsersModel.Insert(l.ctx, user); err != nil {
		return nil, err
	}
	user, err = l.svcCtx.UsersModel.FindOne(l.ctx, user.Id)
	if err != nil {
		return nil, err
	}
	return &types.UserResp{Data: shared.MapUser(user)}, nil
}
