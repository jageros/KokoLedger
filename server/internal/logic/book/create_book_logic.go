// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package book

import (
	"context"
	"errors"

	"koko/internal/logic/shared"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"

	"github.com/google/uuid"
	"github.com/zeromicro/go-zero/core/logx"
	"github.com/zeromicro/go-zero/core/stores/sqlx"
)

type CreateBookLogic struct {
	logx.Logger
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewCreateBookLogic(ctx context.Context, svcCtx *svc.ServiceContext) *CreateBookLogic {
	return &CreateBookLogic{
		Logger: logx.WithContext(ctx),
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *CreateBookLogic) CreateBook(req *types.CreateBookReq) (resp *types.BookResp, err error) {
	userID, err := shared.CurrentUserID(l.ctx)
	if err != nil {
		return nil, err
	}
	name := utils.Clean(req.Name)
	if name == "" {
		return nil, errors.New("name is required")
	}
	currency := utils.NormalizeCurrency(req.DefaultCurrencyCode)
	if err := utils.ValidateCurrency(currency); err != nil {
		return nil, err
	}

	bookID := uuid.NewString()
	err = l.svcCtx.Conn.TransactCtx(l.ctx, func(ctx context.Context, session sqlx.Session) error {
		if _, err := session.ExecCtx(ctx, `insert into books (id, name, note, default_currency_code, owner_id) values ($1, $2, $3, $4, $5)`,
			bookID, name, shared.NullString(req.Note), currency, userID); err != nil {
			return err
		}
		if _, err := session.ExecCtx(ctx, `insert into book_members (id, book_id, user_id, role, joined_at) values ($1, $2, $3, $4, now())`,
			uuid.NewString(), bookID, userID, utils.RoleEditor); err != nil {
			return err
		}
		return insertDefaultCategories(ctx, session, bookID)
	})
	if err != nil {
		return nil, err
	}

	book, err := l.svcCtx.BooksModel.FindOne(l.ctx, bookID)
	if err != nil {
		return nil, err
	}
	return &types.BookResp{Data: shared.MapBook(book)}, nil
}

func insertDefaultCategories(ctx context.Context, session sqlx.Session, bookID string) error {
	defaults := []struct {
		tp    string
		top   string
		child string
		icon  string
		color string
	}{
		{tp: utils.TypeExpense, top: "餐饮", child: "餐饮其他", icon: "fork.knife", color: "#FF7A45"},
		{tp: utils.TypeIncome, top: "收入", child: "收入其他", icon: "banknote", color: "#36B37E"},
	}
	for i, item := range defaults {
		parentID := uuid.NewString()
		if _, err := session.ExecCtx(ctx, `insert into transaction_categories (id, book_id, name, type, level, parent_id, icon, color_hex, sort_order, is_archived)
values ($1, $2, $3, $4, 'level1', null, $5, $6, $7, false)`, parentID, bookID, item.top, item.tp, item.icon, item.color, i+1); err != nil {
			return err
		}
		if _, err := session.ExecCtx(ctx, `insert into transaction_categories (id, book_id, name, type, level, parent_id, icon, color_hex, sort_order, is_archived)
values ($1, $2, $3, $4, 'level2', $5, $6, $7, 1, false)`, uuid.NewString(), bookID, item.child, item.tp, parentID, item.icon, item.color); err != nil {
			return err
		}
	}
	return nil
}
