// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package category

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"koko/internal/logic/category"
	"koko/internal/svc"
	"koko/internal/types"
)

func UpdateCategoryHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.UpdateCategoryReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := category.NewUpdateCategoryLogic(r.Context(), svcCtx)
		resp, err := l.UpdateCategory(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
