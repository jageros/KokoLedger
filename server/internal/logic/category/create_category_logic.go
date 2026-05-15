// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package category

import (
	"context"
	"errors"

	"koko/internal/logic/shared"
	"koko/internal/model"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/google/uuid"
	"github.com/zeromicro/go-zero/core/logx"
)

type CreateCategoryLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewCreateCategoryLogic(ctx context.Context, svcCtx *svc.ServiceContext) *CreateCategoryLogic {
	return &CreateCategoryLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *CreateCategoryLogic) CreateCategory(req *types.CreateCategoryReq) (resp *types.TransactionCategoryResp, err error) {
	if _, err := shared.RequireWritable(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	name := utils.Clean(req.Name)
	if name == "" {
		return nil, errors.New("name is required")
	}
	tp := req.Type
	if tp == "" {
		tp = utils.TypeExpense
	}
	if err := utils.ValidateTxnType(tp); err != nil {
		return nil, err
	}
	if err := validateCategoryParent(l.ctx, l.svcCtx, req.BookId, tp, req.Level, req.ParentId); err != nil {
		return nil, err
	}
	sortOrder, err := l.svcCtx.TransactionCategories.NextSortOrder(l.ctx, req.BookId, tp, req.Level, req.ParentId)
	if err != nil {
		return nil, err
	}
	category := &model.TransactionCategories{
		Id:        uuid.NewString(),
		BookId:    req.BookId,
		Name:      name,
		Type:      tp,
		Level:     req.Level,
		ParentId:  utils.NullString(req.ParentId),
		Icon:      utils.NullString(req.Icon),
		ColorHex:  utils.NullString(req.ColorHex),
		SortOrder: sortOrder,
	}
	if _, err := l.svcCtx.TransactionCategories.Insert(l.ctx, category); err != nil {
		return nil, err
	}
	category, err = l.svcCtx.TransactionCategories.FindOne(l.ctx, category.Id)
	if err != nil {
		return nil, err
	}

	return &types.TransactionCategoryResp{Data: shared.MapCategory(category)}, nil
}

func validateCategoryParent(ctx context.Context, svcCtx *svc.ServiceContext, bookID, tp, level, parentID string) error {
	if err := utils.ValidateCategoryLevel(level); err != nil {
		return err
	}
	if level == utils.Level1 {
		if parentID != "" {
			return errors.New("level1 category cannot have parentId")
		}
		return nil
	}
	if parentID == "" {
		return errors.New("level2 category requires parentId")
	}
	parent, err := svcCtx.TransactionCategories.FindOneByIdBookIdType(ctx, parentID, bookID, tp)
	if err != nil {
		return shared.NormalizeModelErr(err)
	}
	if parent.Level != utils.Level1 || parent.IsArchived {
		return errors.New("invalid parent category")
	}
	return nil
}
