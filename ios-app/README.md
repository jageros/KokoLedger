# iOS App

抠抠记账 iOS 客户端使用 SwiftUI 构建，架构为 MVVM + Service Layer + Repository。

## 功能

- 登录、注册与当前用户会话。
- 多账本创建、切换、编辑与归档。
- 账本成员邀请、接受邀请、权限调整与移除。
- 收入/支出记账，支持一级与二级分类。
- 最近 7 天、本月、本年、全部范围的统计分析。

## 数据源

App 默认使用本地 Mock Service，方便脱离服务端开发和测试。

当 Info.plist 中配置了 `KOUKOU_API_BASE_URL` 且值为合法 `http/https` URL 时，`AppDependencyContainer` 会自动切换到 Remote Service，并通过 `APIClient` 调用服务端接口。该值为空、空白或非法时继续使用 Mock。

## 目录

- `App/`：应用入口、会话状态、根导航。
- `Core/`：模型、网络、服务协议、仓储、本地数据与工具。
- `Features/`：业务页面与 ViewModel。
- `Shared/`：通用组件和主题。
- `KouKouLedgerTests/`：单元测试。
- `scripts/`：构建、测试、验证脚本。

## 验证

```bash
./scripts/build.sh
./scripts/test.sh
./scripts/verify.sh
```
