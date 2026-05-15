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

type GetStatisticsCategoriesLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewGetStatisticsCategoriesLogic(ctx context.Context, svcCtx *svc.ServiceContext) *GetStatisticsCategoriesLogic {
	return &GetStatisticsCategoriesLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *GetStatisticsCategoriesLogic) GetStatisticsCategories(req *types.StatisticsCategoriesReq) (resp *types.CategoryRatioSliceListResp, err error) {
	if _, _, err := shared.RequireBookAccess(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	if err := utils.ValidateTxnType(req.Type); err != nil {
		return nil, err
	}
	if err := utils.ValidateCategoryLevel(req.Level); err != nil {
		return nil, err
	}
	start, end, err := utils.ScopeRange(req.Scope, req.RelativeTo)
	if err != nil {
		return nil, err
	}
	rows, err := l.svcCtx.LedgerTransactions.CategoryRatios(l.ctx, req.BookId, req.Type, req.Level, start, end)
	if err != nil {
		return nil, err
	}
	var total int64
	for _, row := range rows {
		total += row.AmountMinor
	}
	data := make([]types.CategoryRatioSlice, 0, len(rows))
	for _, row := range rows {
		var pct float64
		if total > 0 {
			pct = float64(row.AmountMinor) / float64(total)
		}
		data = append(data, types.CategoryRatioSlice{
			Id:           row.CategoryId,
			CategoryId:   row.CategoryId,
			CategoryName: row.CategoryName,
			AmountMinor:  row.AmountMinor,
			Percentage:   pct,
		})
	}

	return &types.CategoryRatioSliceListResp{Data: data}, nil
}
