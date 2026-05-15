# Security

安全与权限相关目录。

- `AuthTokenStore` 保存当前运行期 Bearer token。
- `KeychainService` 预留持久化敏感信息能力。
- `PermissionGuard` 集中判断账本、成员、分类和记账权限。

UI 隐藏入口不能替代 Service 层权限校验。
