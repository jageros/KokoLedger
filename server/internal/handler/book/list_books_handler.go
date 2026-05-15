// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package book

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"koko/internal/logic/book"
	"koko/internal/svc"
)

func ListBooksHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		l := book.NewListBooksLogic(r.Context(), svcCtx)
		resp, err := l.ListBooks()
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
