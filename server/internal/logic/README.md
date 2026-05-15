# logic

业务逻辑层。

handler 只负责解析请求和返回响应；权限判断、数据库读写、事务编排、错误包装应放在 logic。多个模块复用的业务 helper 可放在 `shared/`。
