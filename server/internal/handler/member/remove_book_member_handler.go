// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package member

import (
	"net/http"

	"github.com/zeromicro/go-zero/rest/httpx"
	"koko/internal/logic/member"
	"koko/internal/svc"
	"koko/internal/types"
)

func RemoveBookMemberHandler(svcCtx *svc.ServiceContext) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		var req types.RemoveMemberReq
		if err := httpx.Parse(r, &req); err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
			return
		}

		l := member.NewRemoveBookMemberLogic(r.Context(), svcCtx)
		resp, err := l.RemoveBookMember(&req)
		if err != nil {
			httpx.ErrorCtx(r.Context(), w, err)
		} else {
			httpx.OkJsonCtx(r.Context(), w, resp)
		}
	}
}
