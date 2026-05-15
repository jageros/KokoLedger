# API 文档

这里存放 go-zero `.api` 契约源文件，入口为 `koko.api`。

## 规则

- 按功能拆分 auth、book、member、invite、category、transaction、statistics。
- iOS 端路径必须与 `ios-app/Core/Networking/APIEndpoint.swift` 保持一致。
- 登录/注册公开；其他业务接口使用 JWT 和 `SessionAuth` 中间件。
- API 响应对外保持 camelCase JSON。

## 验证

```bash
goctl api validate --api doc/api/koko.api
make api
```
