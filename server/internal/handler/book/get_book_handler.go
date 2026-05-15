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

func GetBookHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.BookPathReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := book.NewGetBookLogic(r.Context(), svcCtx)
		resp, err := l.GetBook(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
