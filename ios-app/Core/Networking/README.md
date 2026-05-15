# Networking

网络基础设施目录。

- `BackendMode` 和 `BackendConfiguration` 决定使用 Mock 还是 Remote。
- `APIEndpoint` 是 iOS 与服务端路径契约的本地镜像。
- `APIClient` 负责组装 URL、JSON 编解码、Bearer token 和 HTTP 状态映射。

配置 `KOUKOU_API_BASE_URL` 后，App 会自动使用 Remote Service；未配置时使用 Mock。
