# Services

Service Layer 定义业务能力边界。

- `ServiceProtocols.swift` 是 ViewModel/Repository 依赖的抽象协议。
- `Mock/` 用本地内存数据实现完整业务规则，默认用于开发和测试。
- `Remote/` 通过 `APIClient` 调用 go-zero 服务端接口。

新增业务能力时先扩展协议，再同步 Mock 和 Remote 实现。
