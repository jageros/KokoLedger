// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package book

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"koko/internal/logic/book"
	"koko/internal/svc"
	"koko/internal/types"
)

func UpdateBookHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.UpdateBookReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := book.NewUpdateBookLogic(r.Context(), svcCtx)
		resp, err := l.UpdateBook(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
