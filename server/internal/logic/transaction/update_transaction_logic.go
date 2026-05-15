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
	if _, err := shared.RequireWritable(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	existing, err := l.svcCtx.LedgerTransactions.FindOneByBookID(l.ctx, req.BookId, req.TransactionId)
	if err != nil {
		return nil, shared.NormalizeModelErr(err)
	}
	txn, err := buildTransaction(l.ctx, l.svcCtx, req.BookId, existing.Id, req.Type, req.AmountMinor, req.CurrencyCode, req.CategoryLevel1Id, req.CategoryLevel2Id, req.OccurredAt, req.Note, existing.CreatedBy)
	if err != nil {
		return nil, err
	}
	txn.DeletedAt = existing.DeletedAt
	if err := l.svcCtx.LedgerTransactions.Update(l.ctx, txn); err != nil {
		return nil, err
	}
	txn, err = l.svcCtx.LedgerTransactions.FindOneByBookID(l.ctx, req.BookId, req.TransactionId)
	if err != nil {
		return nil, err
	}

	return &types.LedgerTransactionResp{Data: shared.MapTransaction(txn)}, nil
}
