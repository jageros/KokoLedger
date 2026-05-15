// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package statistics

import (
	"context"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/zeromicro/go-zero/core/logx"
)

type GetStatisticsTrendLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewGetStatisticsTrendLogic(ctx context.Context, svcCtx *svc.ServiceContext) *GetStatisticsTrendLogic {
	return &GetStatisticsTrendLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *GetStatisticsTrendLogic) GetStatisticsTrend(req *types.StatisticsScopeReq) (resp *types.TrendPointListResp, err error) {
	if _, _, err := shared.RequireBookAccess(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	start, end, err := utils.ScopeRange(req.Scope, req.RelativeTo)
	if err != nil {
		return nil, err
	}
	points, err := l.svcCtx.LedgerTransactions.Trend(l.ctx, req.BookId, start, end)
	if err != nil {
		return nil, err
	}
	data := make([]types.TrendPoint, 0, len(points))
	for _, point := range points {
		date := point.Date.Format("2006-01-02")
		data = append(data, types.TrendPoint{
			Id:           date,
			Date:         date,
			IncomeMinor:  point.IncomeMinor,
			ExpenseMinor: point.ExpenseMinor,
		})
	}

	return &types.TrendPointListResp{Data: data}, nil
}
