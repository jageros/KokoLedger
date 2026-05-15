package shared

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"koko/internal/model"
	"koko/internal/pkg/authsession"
	"koko/internal/svc"
	"koko/internal/types"
	"koko/internal/utils"
)

var (
	ErrForbidden = errors.New("forbidden")
	ErrNotFound  = errors.New("not found")
)

func CurrentUserID(ctx context.Context) (string, error) {
	return authsession.UserIDFromContext(ctx)
}

func CurrentSessionID(ctx context.Context) (string, error) {
	return authsession.SessionIDFromContext(ctx)
}

func RequireBookAccess(ctx context.Context, svcCtx *svc.ServiceContext, bookID string) (*model.Books, string, error) {
	userID, err := CurrentUserID(ctx)
	if err != nil {
		return nil, "", err
	}
	book, err := svcCtx.BooksModel.FindOne(ctx, bookID)
	if err != nil {
		return nil, "", normalizeModelErr(err)
	}
	if book.ArchivedAt.Valid {
		return nil, "", ErrNotFound
	}
	if book.OwnerId == userID {
		return book, "owner", nil
	}
	member, err := svcCtx.BookMembersModel.FindOneByBookIdUserId(ctx, bookID, userID)
	if err != nil {
		return nil, "", normalizeModelErr(err)
	}
	return book, member.Role, nil
}

func RequireOwner(ctx context.Context, svcCtx *svc.ServiceContext, bookID string) (*model.Books, error) {
	book, role, err := RequireBookAccess(ctx, svcCtx, bookID)
	if err != nil {
		return nil, err
	}
	if role != "owner" {
		return nil, ErrForbidden
	}
	return book, nil
}

func RequireWritable(ctx context.Context, svcCtx *svc.ServiceContext, bookID string) (*model.Books, error) {
	book, role, err := RequireBookAccess(ctx, svcCtx, bookID)
	if err != nil {
		return nil, err
	}
	if role != "owner" && role != utils.RoleEditor {
		return nil, ErrForbidden
	}
	return book, nil
}

func MapUser(user *model.Users) types.User {
	return types.User{
		Id:        user.Id,
		Nickname:  user.Nickname,
		AvatarURL: utils.StringFromNull(user.AvatarUrl),
		Email:     utils.StringFromNull(user.Email),
		Phone:     utils.StringFromNull(user.Phone),
		CreatedAt: utils.FormatTime(user.CreatedAt),
		UpdatedAt: utils.FormatTime(user.UpdatedAt),
	}
}

func MapBook(book *model.Books) types.Book {
	return types.Book{
		Id:                  book.Id,
		Name:                book.Name,
		Note:                utils.StringFromNull(book.Note),
		DefaultCurrencyCode: book.DefaultCurrencyCode,
		OwnerId:             book.OwnerId,
		CreatedAt:           utils.FormatTime(book.CreatedAt),
		UpdatedAt:           utils.FormatTime(book.UpdatedAt),
		ArchivedAt:          utils.NullTimeString(book.ArchivedAt),
	}
}

func MapMember(member *model.BookMembers) types.BookMember {
	return types.BookMember{
		Id:       member.Id,
		BookId:   member.BookId,
		UserId:   member.UserId,
		Role:     member.Role,
		JoinedAt: utils.FormatTime(member.JoinedAt),
	}
}

func MapInvite(invite *model.BookInvites) types.BookInvite {
	return types.BookInvite{
		Id:              invite.Id,
		BookId:          invite.BookId,
		InviteCode:      invite.InviteCode,
		InviteLink:      utils.StringFromNull(invite.InviteLink),
		InvitedByUserId: invite.InvitedByUserId,
		Role:            invite.Role,
		Status:          invite.Status,
		ExpiresAt:       utils.FormatTime(invite.ExpiresAt),
		CreatedAt:       utils.FormatTime(invite.CreatedAt),
		AcceptedAt:      utils.NullTimeString(invite.AcceptedAt),
	}
}

func MapCategory(category *model.TransactionCategories) types.TransactionCategory {
	return types.TransactionCategory{
		Id:         category.Id,
		BookId:     category.BookId,
		Name:       category.Name,
		Type:       category.Type,
		Level:      category.Level,
		ParentId:   utils.StringFromNull(category.ParentId),
		Icon:       utils.StringFromNull(category.Icon),
		ColorHex:   utils.StringFromNull(category.ColorHex),
		SortOrder:  category.SortOrder,
		IsArchived: category.IsArchived,
		CreatedAt:  utils.FormatTime(category.CreatedAt),
		UpdatedAt:  utils.FormatTime(category.UpdatedAt),
	}
}

func MapTransaction(txn *model.LedgerTransactions) types.LedgerTransaction {
	return types.LedgerTransaction{
		Id:               txn.Id,
		BookId:           txn.BookId,
		Type:             txn.Type,
		AmountMinor:      txn.AmountMinor,
		CurrencyCode:     txn.CurrencyCode,
		CategoryLevel1Id: txn.CategoryLevel1Id,
		CategoryLevel2Id: txn.CategoryLevel2Id,
		OccurredAt:       utils.FormatTime(txn.OccurredAt),
		Note:             utils.StringFromNull(txn.Note),
		CreatedBy:        txn.CreatedBy,
		CreatedAt:        utils.FormatTime(txn.CreatedAt),
		UpdatedAt:        utils.FormatTime(txn.UpdatedAt),
		DeletedAt:        utils.NullTimeString(txn.DeletedAt),
	}
}

func SummaryResp(summary model.TransactionSummary) types.LedgerSummary {
	return types.LedgerSummary{
		TotalIncomeMinor:  summary.IncomeMinor,
		TotalExpenseMinor: summary.ExpenseMinor,
		BalanceMinor:      summary.IncomeMinor - summary.ExpenseMinor,
		CurrencyCode:      summary.CurrencyCode,
	}
}

func PercentageDelta(current, previous int64) types.PercentageDelta {
	if previous == 0 {
		if current == 0 {
			return types.PercentageDelta{Kind: "flat"}
		}
		return types.PercentageDelta{Kind: "new"}
	}
	return types.PercentageDelta{Kind: "percent", Value: float64(current-previous) / float64(previous)}
}

func AveragePerDay(amount int64, start, end time.Time) int64 {
	if start.IsZero() || end.IsZero() || !end.After(start) {
		return amount
	}
	days := int64(end.Sub(start).Hours() / 24)
	if days < 1 {
		days = 1
	}
	return amount / days
}

func NormalizeModelErr(err error) error {
	return normalizeModelErr(err)
}

func normalizeModelErr(err error) error {
	if err == nil {
		return nil
	}
	if errors.Is(err, model.ErrNotFound) {
		return ErrNotFound
	}
	return err
}

func NullString(value string) sql.NullString {
	return utils.NullString(value)
}
