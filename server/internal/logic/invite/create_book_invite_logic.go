// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package invite

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

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
	// todo: add your logic here and delete this line

	return
}
