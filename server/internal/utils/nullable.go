package utils

import (
	"database/sql"
	"strings"
	"time"
)

func NullString(value string) sql.NullString {
	value = strings.TrimSpace(value)
	return sql.NullString{String: value, Valid: value != ""}
}

func StringFromNull(value sql.NullString) string {
	if !value.Valid {
		return ""
	}
	return value.String
}

func NullTimeString(value sql.NullTime) string {
	if !value.Valid {
		return ""
	}
	return FormatTime(value.Time)
}

func NullTime(t time.Time) sql.NullTime {
	return sql.NullTime{Time: t, Valid: !t.IsZero()}
}
