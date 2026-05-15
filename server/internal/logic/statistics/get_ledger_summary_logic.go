// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package statistics

import (
	"context"

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
	// todo: add your logic here and delete this line

	return
}
