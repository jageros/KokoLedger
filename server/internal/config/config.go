// Code scaffolded by goctl. Safe to edit.
// goctl 1.9.2

package config

import (
	"fmt"

	"github.com/zeromicro/go-zero/core/stores/sqlx"
	"github.com/zeromicro/go-zero/rest"
)

type Config struct {
	rest.RestConf
	Postgres PostgresConf
}

type PostgresConf struct {
	Addr     string
	Database string
	User     string
	Password string
}

func (p PostgresConf) Dsn() string {
	return fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable", p.User, p.Password, p.Addr, p.Database)
}

func (p PostgresConf) Conn() sqlx.SqlConn {
	return sqlx.NewSqlConn("postgres", p.Dsn())
}
