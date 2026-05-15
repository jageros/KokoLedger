# Core

客户端核心层，承载可复用业务基础设施。

- `Models/` 定义领域模型。
- `Networking/` 定义后端模式、接口路径和 APIClient。
- `Services/` 定义服务协议及 Mock/Remote 实现。
- `Repositories/` 为 ViewModel 提供稳定的数据访问入口。
- `Storage/` 保留 Mock 数据和 SwiftData 本地缓存能力。
- `Security/` 处理 token、Keychain 和权限判断。
- `Utils/` 存放金额、日期、百分比和校验工具。
