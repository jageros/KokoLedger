// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package transaction

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"koko/internal/logic/transaction"
	"koko/internal/svc"
	"koko/internal/types"
)

func DeleteTransactionHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.TransactionPathReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := transaction.NewDeleteTransactionLogic(r.Context(), svcCtx)
		resp, err := l.DeleteTransaction(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
