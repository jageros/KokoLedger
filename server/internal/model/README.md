# model

数据库模型目录。

- `*_gen.go` 由 goctl 生成，禁止手改。
- `*_model.go` 可写自定义查询、软删除、聚合和事务辅助方法。
- 数据库结构变更先写 `doc/migrations/`，再生成模型。
