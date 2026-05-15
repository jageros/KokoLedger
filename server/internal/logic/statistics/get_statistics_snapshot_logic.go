// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package statistics

import (
	"context"

	"koko/internal/svc"
	"koko/internal/types"

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
	// todo: add your logic here and delete this line

	return
}
