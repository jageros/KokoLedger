# Goose Migrations

这里存放 PostgreSQL goose 迁移文件，是数据库结构的源头。

## 规则

- 文件名使用递增编号，例如 `000001_create_common_extensions.sql`。
- 每个文件必须包含 `-- +goose Up` 和 `-- +goose Down`。
- 主键使用 UUID，时间字段使用 `timestamptz`，金额使用 minor unit 整数。
- 迁移变更后再生成 `internal/model` 下的数据库模型。

## 验证

```bash
goose -dir doc/migrations postgres "$DSN" up
goose -dir doc/migrations postgres "$DSN" status
goose -dir doc/migrations postgres "$DSN" down-to 0
```
