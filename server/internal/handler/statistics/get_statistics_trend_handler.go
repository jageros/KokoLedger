// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package statistics

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"koko/internal/logic/statistics"
	"koko/internal/svc"
	"koko/internal/types"
)

func GetStatisticsTrendHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.StatisticsScopeReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := statistics.NewGetStatisticsTrendLogic(r.Context(), svcCtx)
		resp, err := l.GetStatisticsTrend(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
