# koko-pro

抠抠记账是一个多人协作记账项目，包含 SwiftUI iOS 客户端与 Go/go-zero 服务端。

## 目录

```text
koko-pro/
├── ios-app/                 # iOS App，SwiftUI + MVVM + Service/Repository
├── server/                  # 服务端，Go + go-zero + PostgreSQL
└── README.md                # 项目总览
```

## 子项目

- `ios-app/`：客户端工程，默认使用 Mock 数据；配置 `KOUKOU_API_BASE_URL` 后切换到服务端 API。
- `server/`：服务端工程，API 契约在 `doc/api/`，数据库迁移在 `doc/migrations/`。

## 常用验证

```bash
cd ios-app && ./scripts/verify.sh
cd server && go test ./...
```

服务端 API 变更先改 `server/doc/api/*.api`，数据库结构变更先写 `server/doc/migrations/*.sql`。
