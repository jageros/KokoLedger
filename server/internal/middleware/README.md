# middleware

HTTP 中间件目录。

当前 `SessionAuth` 在 go-zero JWT 之后运行，负责校验 session 存在、未过期、未撤销，并与 token claims 匹配。通用认证校验应保留在中间件，不下放到各业务 logic。
