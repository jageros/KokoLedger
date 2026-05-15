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

type GetTransactionLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewGetTransactionLogic(ctx context.Context, svcCtx *svc.ServiceContext) *GetTransactionLogic {
	return &GetTransactionLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *GetTransactionLogic) GetTransaction(req *types.TransactionPathReq) (resp *types.LedgerTransactionResp, err error) {
	if _, _, err := shared.RequireBookAccess(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	txn, err := l.svcCtx.LedgerTransactions.FindOneByBookID(l.ctx, req.BookId, req.TransactionId)
	if err != nil {
		return nil, shared.NormalizeModelErr(err)
	}

	return &types.LedgerTransactionResp{Data: shared.MapTransaction(txn)}, nil
}
