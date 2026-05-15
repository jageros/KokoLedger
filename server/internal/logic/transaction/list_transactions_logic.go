// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package transaction

import (
	"context"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/zeromicro/go-zero/core/logx"
)

type ListTransactionsLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewListTransactionsLogic(ctx context.Context, svcCtx *svc.ServiceContext) *ListTransactionsLogic {
	return &ListTransactionsLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *ListTransactionsLogic) ListTransactions(req *types.ListTransactionsReq) (resp *types.LedgerTransactionListResp, err error) {
	if _, _, err := shared.RequireBookAccess(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	from, err := utils.OptionalParseTime(req.From)
	if err != nil {
		return nil, err
	}
	to, err := utils.OptionalParseTime(req.To)
	if err != nil {
		return nil, err
	}
	txns, err := l.svcCtx.LedgerTransactions.FindManyByBook(l.ctx, req.BookId, from, to)
	if err != nil {
		return nil, err
	}
	data := make([]types.LedgerTransaction, 0, len(txns))
	for _, txn := range txns {
		data = append(data, shared.MapTransaction(txn))
	}

	return &types.LedgerTransactionListResp{Data: data}, nil
}
