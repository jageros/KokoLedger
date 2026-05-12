# koko-pro

抠抠记账 App，包含 iOS 客户端与 Go 服务端两个主要部分。

## 项目目录结构

```text
koko-pro/
├── ios-app/                 # iOS App 代码（SwiftUI）
├── server/                  # 服务端代码（Go + go-zero）
│   ├── doc/
│   │   └── api/             # go-zero 的 API 定义文档
│   └── migrations/          # goose 管理的 PostgreSQL 迁移结构文档
└── README.md                # 项目总览文档
```

## 子目录说明（基于各目录 README）

### `ios-app/`

- 存放 iOS App 代码。
- 技术栈：SwiftUI。

### `server/`

- 存放服务端代码。
- 技术栈：Go、go-zero 框架。

### `server/doc/api/`

- 存放 go-zero 的 API 定义文档。

### `server/migrations/`

- 存放由 goose 管理的 PostgreSQL 数据库迁移（表结构定义）文档。
