# internal

服务端内部实现目录。

- `handler/` 是 goctl 生成/脚手架 HTTP 入口。
- `logic/` 承载业务流程、权限判断和数据编排。
- `model/` 是数据库模型和自定义查询扩展。
- `middleware/` 放通用 HTTP 中间件。
- `pkg/` 放完整职责的通用功能包。
- `utils/` 放轻量工具函数。
- `svc/` 初始化配置、连接、模型和长期依赖。
