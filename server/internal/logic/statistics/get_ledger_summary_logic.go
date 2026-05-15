// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package statistics

import (
	"context"
	"time"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"

	"github.com/zeromicro/go-zero/core/logx"
)

type GetLedgerSummaryLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewGetLedgerSummaryLogic(ctx context.Context, svcCtx *svc.ServiceContext) *GetLedgerSummaryLogic {
	return &GetLedgerSummaryLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *GetLedgerSummaryLogic) GetLedgerSummary(req *types.BookStatisticsReq) (resp *types.LedgerSummaryResp, err error) {
	if _, _, err := shared.RequireBookAccess(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	summary, err := l.svcCtx.LedgerTransactions.Summary(l.ctx, req.BookId, zeroTime(), zeroTime())
	if err != nil {
		return nil, err
	}

	return &types.LedgerSummaryResp{Data: shared.SummaryResp(summary)}, nil
}

func zeroTime() time.Time { return time.Time{} }
