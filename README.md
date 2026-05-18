# koko-pro

简体中文 | [English](./README.en.md)

抠抠记账是一个面向多人协作场景的记账项目，包含 SwiftUI iOS 客户端与 Go/go-zero 服务端。它支持多账本、成员协作、收入/支出分类、交易记录和统计分析，适合个人记账、家庭账本以及小团队共享账本等场景。

> 项目仍处于早期开发阶段，接口、界面和部署方式可能继续调整。

## 功能亮点

- 多账本管理：创建、切换、编辑和归档账本。
- 成员协作：通过邀请码邀请成员加入账本，支持只读和可编辑角色。
- 分类记账：支持收入/支出、一级分类和二级分类。
- 交易管理：创建、编辑、查看和软删除记账记录。
- 统计分析：支持账本汇总、统计快照、趋势和分类占比。
- Mock 优先开发：iOS 默认使用本地 Mock 服务，未配置后端时也能运行和测试。
- 服务端同步：配置 `KOUKOU_API_BASE_URL` 后，iOS 自动切换到服务端 API。

## 技术栈

### iOS

- SwiftUI
- MVVM
- Service Layer
- Repository
- XCTest

### Server

- Go
- go-zero
- PostgreSQL
- goose
- goctl

## 项目结构

```text
koko-pro/
├── ios-app/                 # iOS App，SwiftUI + MVVM + Service/Repository
├── server/                  # 服务端，Go + go-zero + PostgreSQL
├── README.md                # 中文首页文档
├── README.en.md             # English README
└── LICENSE                  # MIT License
```

更多目录说明请查看：

- [iOS App 文档](./ios-app/README.md)
- [Server 文档](./server/README.md)
- [API 契约文档](./server/doc/api/README.md)
- [数据库迁移文档](./server/doc/migrations/README.md)

## 快速开始

### 1. 克隆项目

```bash
git clone <repo-url>
cd koko-pro
```

### 2. 运行 iOS App

iOS App 默认使用本地 Mock 数据，不依赖服务端即可构建、运行和测试。

```bash
cd ios-app
./scripts/verify.sh
```

也可以直接用 Xcode 打开：

```bash
open KouKouLedger.xcodeproj
```

### 3. 启用服务端数据

当 iOS App 的 Info.plist 中配置了合法的 `http/https` 地址时，应用会自动使用远程服务端数据：

```text
KOUKOU_API_BASE_URL=https://your-api.example.com
```

如果该值为空、空白或非法，App 会继续使用本地 Mock 服务。数据源选择集中在 `AppDependencyContainer`，业务页面和 ViewModel 不需要关心当前使用 Mock 还是 Remote。

### 4. 启动服务端

服务端配置位于 `server/etc/koko.yaml`，默认监听 `8888` 端口，并使用 PostgreSQL。

```bash
cd server
make init
make migrate
go test ./...
go run koko.go -f etc/koko.yaml
```

默认开发数据库参数可通过 `server/Makefile` 的变量覆盖：

```bash
make migrate host=127.0.0.1:5432 user=biroot pwd=123456 database=koko
```

## 开发工作流

### API 变更

服务端 API 使用 go-zero `.api` 文件作为源头。修改接口、路由、handler 参数或 types 时，请先改：

```text
server/doc/api/*.api
```

然后在 `server/` 下执行：

```bash
make api
```

不要手动修改 goctl 生成文件。

### 数据库变更

数据库结构使用 goose 迁移作为源头。修改表结构时，请先新增或修改：

```text
server/doc/migrations/*.sql
```

然后执行迁移和模型生成：

```bash
cd server
make migrate
make model-all
```

### iOS 数据源

iOS 默认使用 Mock 服务，适合离线开发、单元测试和 UI 调试。配置 `KOUKOU_API_BASE_URL` 后自动切换为 Remote 服务，并通过 `APIClient` 调用服务端接口。

## 常用验证

```bash
cd ios-app && ./scripts/verify.sh
cd server && go test ./...
git diff --check
```

如果本机缺少可用 iOS Simulator runtime，`ios-app/scripts/verify.sh` 可能无法跑完整测试；此时可以先使用 Xcode 环境检查和 Swift 解析检查定位问题。

## API 与数据模型

服务端 API 覆盖以下模块：

- Auth：注册、登录、登出、当前用户。
- Books：账本列表、详情、创建、编辑、归档。
- Members：成员列表、角色修改、移除成员。
- Invites：创建邀请、邀请列表、接受邀请、撤销邀请。
- Categories：分类列表、创建、编辑、归档。
- Transactions：记账列表、创建、详情、编辑、删除。
- Statistics：账本汇总、统计快照、趋势、分类占比。

数据库使用 PostgreSQL，核心表包括 `users`、`auth_sessions`、`books`、`book_members`、`book_invites`、`transaction_categories` 和 `ledger_transactions`。

## 截图与演示

截图和演示内容待补充。当前项目优先完善 iOS 功能闭环、服务端接口和本地验证流程。

## 贡献

欢迎通过 Issue 或 Pull Request 参与项目。提交变更前请尽量：

- 保持改动聚焦，避免混入无关格式化。
- API 变更先更新 `server/doc/api/*.api`。
- 数据库变更先更新 `server/doc/migrations/*.sql`。
- iOS 变更优先运行 `cd ios-app && ./scripts/verify.sh`。
- Server 变更优先运行 `cd server && go test ./...`。

## License

本项目基于 [MIT License](./LICENSE) 开源。
