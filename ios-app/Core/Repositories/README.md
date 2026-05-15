# Repositories

Repository 是 ViewModel 面向数据层的入口。

本目录将 Service Protocol 包装为更稳定的调用面，避免页面直接依赖 Mock 或 Remote 细节。数据源选择由 `AppDependencyContainer` 统一完成。
