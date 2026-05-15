# Storage

本地数据和缓存相关目录。

- `MockSeedData` 提供测试与 Mock 服务的初始数据。
- `MockDataStore` 是 Mock Service 的内存数据源。
- `SwiftDataLocalCacheService` 为后续离线缓存预留。

业务规则优先放在 Service 或专用规则工具中，不直接塞进存储层。
