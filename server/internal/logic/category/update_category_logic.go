// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package category

import (
	"context"
	"errors"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/zeromicro/go-zero/core/logx"
)

type UpdateCategoryLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewUpdateCategoryLogic(ctx context.Context, svcCtx *svc.ServiceContext) *UpdateCategoryLogic {
	return &UpdateCategoryLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *UpdateCategoryLogic) UpdateCategory(req *types.UpdateCategoryReq) (resp *types.TransactionCategoryResp, err error) {
	if _, err := shared.RequireWritable(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	if err := utils.ValidateTxnType(req.Type); err != nil {
		return nil, err
	}
	if err := validateCategoryParent(l.ctx, l.svcCtx, req.BookId, req.Type, req.Level, req.ParentId); err != nil {
		return nil, err
	}
	name := utils.Clean(req.Name)
	if name == "" {
		return nil, errors.New("name is required")
	}
	category, err := l.svcCtx.TransactionCategories.FindOneByIdBookIdType(l.ctx, req.CategoryId, req.BookId, req.Type)
	if err != nil {
		return nil, shared.NormalizeModelErr(err)
	}
	category.Name = name
	category.Type = req.Type
	category.Level = req.Level
	category.ParentId = utils.NullString(req.ParentId)
	category.Icon = utils.NullString(req.Icon)
	category.ColorHex = utils.NullString(req.ColorHex)
	category.SortOrder = req.SortOrder
	category.IsArchived = req.IsArchived
	if err := l.svcCtx.TransactionCategories.Update(l.ctx, category); err != nil {
		return nil, err
	}
	category, err = l.svcCtx.TransactionCategories.FindOne(l.ctx, category.Id)
	if err != nil {
		return nil, err
	}

	return &types.TransactionCategoryResp{Data: shared.MapCategory(category)}, nil
}
