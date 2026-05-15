# KouKouLedger 工程规则

1. 必须遵循 design.md。
2. App 主信息架构固定为：
   - 首页
   - 统计
   - 我的
3. 使用 SwiftUI。
4. 使用 Swift Charts 实现统计图表。
5. 使用 SwiftData 作为本地缓存或本地数据层预留。
6. 架构使用 MVVM + Service Layer + Repository。
7. View 中不能写复杂业务逻辑。
8. 统计逻辑必须放在 StatisticsService。
9. 权限逻辑必须放在 PermissionGuard。
10. 金额不能使用 Double 存储，必须使用 Int64 amountMinor。
11. 百分比、图表占比可以使用 Double，但不能作为金额存储。
12. 所有 Service 必须通过 Protocol 抽象，方便后续替换真实后端。
13. 默认未配置服务端地址时使用 Mock Service；配置 `KOUKOU_API_BASE_URL` 后使用 Remote Service。
14. 每完成一个阶段必须运行 xcodebuild build。
15. 如果有测试，必须运行 xcodebuild test。
16. 不允许把大量代码写进一个文件。
17. 不允许为了编译通过删除核心业务规则。
18. 所有权限入口在 UI 层隐藏的同时，Service 层也必须做二次校验。
