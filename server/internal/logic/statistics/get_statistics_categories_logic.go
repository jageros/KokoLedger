// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package statistics

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

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
	// todo: add your logic here and delete this line

	return
}
