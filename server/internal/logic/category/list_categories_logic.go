// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package category

import (
	"context"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/zeromicro/go-zero/core/logx"
)

type ListCategoriesLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewListCategoriesLogic(ctx context.Context, svcCtx *svc.ServiceContext) *ListCategoriesLogic {
	return &ListCategoriesLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *ListCategoriesLogic) ListCategories(req *types.ListCategoriesReq) (resp *types.TransactionCategoryListResp, err error) {
	if _, _, err := shared.RequireBookAccess(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	if req.Type != "" {
		if err := utils.ValidateTxnType(req.Type); err != nil {
			return nil, err
		}
	}
	categories, err := l.svcCtx.TransactionCategories.FindManyByBook(l.ctx, req.BookId, req.Type, req.IncludeArchived)
	if err != nil {
		return nil, err
	}
	data := make([]types.TransactionCategory, 0, len(categories))
	for _, category := range categories {
		data = append(data, shared.MapCategory(category))
	}

	return &types.TransactionCategoryListResp{Data: data}, nil
}
