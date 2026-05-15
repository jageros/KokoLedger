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

type GetStatisticsSnapshotLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewGetStatisticsSnapshotLogic(ctx context.Context, svcCtx *svc.ServiceContext) *GetStatisticsSnapshotLogic {
	return &GetStatisticsSnapshotLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *GetStatisticsSnapshotLogic) GetStatisticsSnapshot(req *types.StatisticsScopeReq) (resp *types.StatisticsSnapshotResp, err error) {
	if _, _, err := shared.RequireBookAccess(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	start, end, err := utils.ScopeRange(req.Scope, req.RelativeTo)
	if err != nil {
		return nil, err
	}
	current, err := l.svcCtx.LedgerTransactions.Summary(l.ctx, req.BookId, start, end)
	if err != nil {
		return nil, err
	}
	prevStart, prevEnd := utils.PreviousRange(start, end)
	previous, err := l.svcCtx.LedgerTransactions.Summary(l.ctx, req.BookId, prevStart, prevEnd)
	if err != nil {
		return nil, err
	}
	avgIncome := shared.AveragePerDay(current.IncomeMinor, start, end)
	avgExpense := shared.AveragePerDay(current.ExpenseMinor, start, end)
	prevAvgIncome := shared.AveragePerDay(previous.IncomeMinor, prevStart, prevEnd)
	prevAvgExpense := shared.AveragePerDay(previous.ExpenseMinor, prevStart, prevEnd)
	scope := req.Scope
	if scope == "" {
		scope = "thisMonth"
	}

	return &types.StatisticsSnapshotResp{Data: types.StatisticsSnapshot{
		Scope:                    scope,
		TotalIncomeMinor:         current.IncomeMinor,
		IncomeDelta:              shared.PercentageDelta(current.IncomeMinor, previous.IncomeMinor),
		TotalExpenseMinor:        current.ExpenseMinor,
		ExpenseDelta:             shared.PercentageDelta(current.ExpenseMinor, previous.ExpenseMinor),
		NetAssetMinor:            current.IncomeMinor - current.ExpenseMinor,
		AverageDailyIncomeMinor:  avgIncome,
		AverageDailyIncomeDelta:  shared.PercentageDelta(avgIncome, prevAvgIncome),
		AverageDailyExpenseMinor: avgExpense,
		AverageDailyExpenseDelta: shared.PercentageDelta(avgExpense, prevAvgExpense),
		CurrencyCode:             current.CurrencyCode,
	}}, nil
}
