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

func GetStatisticsCategoriesHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.StatisticsCategoriesReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := statistics.NewGetStatisticsCategoriesLogic(r.Context(), svcCtx)
		resp, err := l.GetStatisticsCategories(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
