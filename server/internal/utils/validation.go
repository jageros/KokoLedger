package utils

import (
	"errors"
	"net/mail"
	"strings"
)

const (
	RoleReadonly = "readonly"
	RoleEditor   = "editor"
	TypeIncome   = "income"
	TypeExpense  = "expense"
	Level1       = "level1"
	Level2       = "level2"
)

func Clean(value string) string {
	return strings.TrimSpace(value)
}

func NormalizeEmail(value string) string {
	return strings.ToLower(Clean(value))
}

func NormalizeCurrency(value string) string {
	value = strings.ToUpper(Clean(value))
	if value == "" {
		return "CNY"
	}
	return value
}

func ValidateEmail(value string) error {
	if value == "" {
		return nil
	}
	if _, err := mail.ParseAddress(value); err != nil {
		return errors.New("invalid email")
	}
	return nil
}

func ValidatePassword(value string) error {
	if len(value) < 8 {
		return errors.New("password must be at least 8 characters")
	}
	return nil
}

func ValidateRole(value string) error {
	if value != RoleReadonly && value != RoleEditor {
		return errors.New("invalid role")
	}
	return nil
}

func ValidateTxnType(value string) error {
	if value != TypeIncome && value != TypeExpense {
		return errors.New("invalid type")
	}
	return nil
}

func ValidateCategoryLevel(value string) error {
	if value != Level1 && value != Level2 {
		return errors.New("invalid level")
	}
	return nil
}

func ValidateCurrency(value string) error {
	if len(value) != 3 {
		return errors.New("invalid currencyCode")
	}
	return nil
}
