package utils

import (
	"errors"
	"time"
)

func FormatTime(t time.Time) string {
	if t.IsZero() {
		return ""
	}
	return t.UTC().Format(time.RFC3339)
}

func ParseTime(value string) (time.Time, error) {
	if value == "" {
		return time.Time{}, errors.New("time is required")
	}
	if t, err := time.Parse(time.RFC3339, value); err == nil {
		return t, nil
	}
	if t, err := time.Parse("2006-01-02", value); err == nil {
		return t, nil
	}
	return time.Time{}, errors.New("invalid time")
}

func OptionalParseTime(value string) (*time.Time, error) {
	if value == "" {
		return nil, nil
	}
	t, err := ParseTime(value)
	if err != nil {
		return nil, err
	}
	return &t, nil
}

func ScopeRange(scope, relativeTo string) (time.Time, time.Time, error) {
	ref := time.Now()
	if relativeTo != "" {
		parsed, err := ParseTime(relativeTo)
		if err != nil {
			return time.Time{}, time.Time{}, err
		}
		ref = parsed
	}
	ref = ref.UTC()
	switch scope {
	case "", "thisMonth":
		start := time.Date(ref.Year(), ref.Month(), 1, 0, 0, 0, 0, time.UTC)
		return start, start.AddDate(0, 1, 0), nil
	case "last7Days":
		end := time.Date(ref.Year(), ref.Month(), ref.Day(), 0, 0, 0, 0, time.UTC).AddDate(0, 0, 1)
		return end.AddDate(0, 0, -7), end, nil
	case "thisYear":
		start := time.Date(ref.Year(), 1, 1, 0, 0, 0, 0, time.UTC)
		return start, start.AddDate(1, 0, 0), nil
	case "all":
		return time.Time{}, time.Time{}, nil
	default:
		return time.Time{}, time.Time{}, errors.New("invalid scope")
	}
}

func PreviousRange(start, end time.Time) (time.Time, time.Time) {
	if start.IsZero() || end.IsZero() || !end.After(start) {
		return time.Time{}, time.Time{}
	}
	d := end.Sub(start)
	return start.Add(-d), start
}
