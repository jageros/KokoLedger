// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package transaction

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type UpdateTransactionLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewUpdateTransactionLogic(ctx context.Context, svcCtx *svc.ServiceContext) *UpdateTransactionLogic {
	return &UpdateTransactionLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *UpdateTransactionLogic) UpdateTransaction(req *types.UpdateTransactionReq) (resp *types.LedgerTransactionResp, err error) {
	// todo: add your logic here and delete this line

	return
}
