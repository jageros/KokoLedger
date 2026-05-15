// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package transaction

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

type CreateTransactionLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewCreateTransactionLogic(ctx context.Context, svcCtx *svc.ServiceContext) *CreateTransactionLogic {
	return &CreateTransactionLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *CreateTransactionLogic) CreateTransaction(req *types.CreateTransactionReq) (resp *types.LedgerTransactionResp, err error) {
	if _, err := shared.RequireWritable(l.ctx, l.svcCtx, req.BookId); err != nil {
		return nil, err
	}
	userID, err := shared.CurrentUserID(l.ctx)
	if err != nil {
		return nil, err
	}
	txn, err := buildTransaction(l.ctx, l.svcCtx, req.BookId, "", req.Type, req.AmountMinor, req.CurrencyCode, req.CategoryLevel1Id, req.CategoryLevel2Id, req.OccurredAt, req.Note, userID)
	if err != nil {
		return nil, err
	}
	if _, err := l.svcCtx.LedgerTransactions.Insert(l.ctx, txn); err != nil {
		return nil, err
	}
	txn, err = l.svcCtx.LedgerTransactions.FindOne(l.ctx, txn.Id)
	if err != nil {
		return nil, err
	}

	return &types.LedgerTransactionResp{Data: shared.MapTransaction(txn)}, nil
}

func buildTransaction(ctx context.Context, svcCtx *svc.ServiceContext, bookID, id, tp string, amount int64, currency, level1ID, level2ID, occurredAt, note, userID string) (*model.LedgerTransactions, error) {
	if err := utils.ValidateTxnType(tp); err != nil {
		return nil, err
	}
	if amount <= 0 {
		return nil, errors.New("amountMinor must be greater than 0")
	}
	currency = utils.NormalizeCurrency(currency)
	if err := utils.ValidateCurrency(currency); err != nil {
		return nil, err
	}
	occurred, err := utils.ParseTime(occurredAt)
	if err != nil {
		return nil, err
	}
	if err := validateTransactionCategories(ctx, svcCtx, bookID, tp, level1ID, level2ID); err != nil {
		return nil, err
	}
	if id == "" {
		id = uuid.NewString()
	}
	return &model.LedgerTransactions{
		Id:               id,
		BookId:           bookID,
		Type:             tp,
		AmountMinor:      amount,
		CurrencyCode:     currency,
		CategoryLevel1Id: level1ID,
		CategoryLevel2Id: level2ID,
		OccurredAt:       occurred,
		Note:             utils.NullString(note),
		CreatedBy:        userID,
	}, nil
}

func validateTransactionCategories(ctx context.Context, svcCtx *svc.ServiceContext, bookID, tp, level1ID, level2ID string) error {
	level1, err := svcCtx.TransactionCategories.FindOneByIdBookIdType(ctx, level1ID, bookID, tp)
	if err != nil {
		return shared.NormalizeModelErr(err)
	}
	level2, err := svcCtx.TransactionCategories.FindOneByIdBookIdType(ctx, level2ID, bookID, tp)
	if err != nil {
		return shared.NormalizeModelErr(err)
	}
	if level1.Level != utils.Level1 || level2.Level != utils.Level2 || !level2.ParentId.Valid || level2.ParentId.String != level1.Id {
		return errors.New("invalid transaction categories")
	}
	if level1.IsArchived || level2.IsArchived {
		return errors.New("category is archived")
	}
	return nil
}
