// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package invite

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"koko/internal/logic/invite"
	"koko/internal/svc"
	"koko/internal/types"
)

func ListBookInvitesHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.ListInvitesReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := invite.NewListBookInvitesLogic(r.Context(), svcCtx)
		resp, err := l.ListBookInvites(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
