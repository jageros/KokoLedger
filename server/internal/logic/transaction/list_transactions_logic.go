// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package transaction

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

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
	// todo: add your logic here and delete this line

	return
}
