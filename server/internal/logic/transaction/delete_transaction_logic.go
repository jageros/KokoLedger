// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package transaction

import (
	"context"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type DeleteTransactionLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewDeleteTransactionLogic(ctx context.Context, svcCtx *svc.ServiceContext) *DeleteTransactionLogic {
	return &DeleteTransactionLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *DeleteTransactionLogic) DeleteTransaction(req *types.TransactionPathReq) (resp *types.EmptyResp, err error) {
	if _, err := shared.RequireWritable(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	if err := l.svcCtx.LedgerTransactions.SoftDelete(l.ctx, req.BookId, req.TransactionId); err != nil {
		return nil, err
	}

	return &types.EmptyResp{}, nil
}
