# server

服务端基于 Go、go-zero、PostgreSQL 开发，为 iOS App 提供认证、账本协作、分类、记账和统计接口。

## 目录

- `doc/api/`：go-zero `.api` 契约源文件。
- `doc/migrations/`：goose PostgreSQL 迁移。
- `internal/`：服务端业务实现。
- `etc/`：运行配置。

## 常用命令

```bash
make api
make model
make model-all
make migrate
go test ./...
```

API、路由、handler 参数或 types 变更时，先改 `doc/api/*.api` 再生成。数据库结构变更时，先写 goose 迁移，再生成模型。
