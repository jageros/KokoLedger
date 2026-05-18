# koko-pro

[简体中文](./README.md) | English

koko-pro is a collaborative bookkeeping project with a SwiftUI iOS app and a Go/go-zero backend. It supports multiple ledgers, shared ledger members, income and expense categories, transactions, and statistics for personal finance, family ledgers, and small shared bookkeeping workflows.

> This project is still in early development. APIs, UI flows, and deployment details may continue to change.

## Highlights

- Multiple ledgers: create, switch, edit, and archive ledgers.
- Collaboration: invite members with invite codes and assign readonly or editor roles.
- Categorized bookkeeping: income and expense records with level-1 and level-2 categories.
- Transaction management: create, edit, inspect, and soft-delete ledger transactions.
- Statistics: ledger summary, snapshots, trends, and category ratios.
- Mock-first development: the iOS app uses local Mock services by default.
- Remote backend support: once `KOUKOU_API_BASE_URL` is configured, the iOS app switches to the server API automatically.

## Tech Stack

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

## Repository Layout

```text
koko-pro/
├── ios-app/                 # iOS app, SwiftUI + MVVM + Service/Repository
├── server/                  # Backend, Go + go-zero + PostgreSQL
├── README.md                # Chinese README
├── README.en.md             # English README
└── LICENSE                  # MIT License
```

More documentation:

- [iOS App README](./ios-app/README.md)
- [Server README](./server/README.md)
- [API Contract README](./server/doc/api/README.md)
- [Database Migration README](./server/doc/migrations/README.md)

## Quick Start

### 1. Clone the repository

```bash
git clone <repo-url>
cd koko-pro
```

### 2. Run the iOS app

The iOS app uses local Mock data by default, so it can be built, run, and tested without the backend.

```bash
cd ios-app
./scripts/verify.sh
```

You can also open the Xcode project directly:

```bash
open KouKouLedger.xcodeproj
```

### 3. Enable remote backend data

When the iOS app has a valid `http/https` URL configured in Info.plist, it automatically switches to the remote backend:

```text
KOUKOU_API_BASE_URL=https://your-api.example.com
```

If the value is empty, blank, or invalid, the app continues to use local Mock services. Backend selection is centralized in `AppDependencyContainer`, so feature views and view models do not branch on Mock vs Remote.

### 4. Run the backend

Backend configuration lives in `server/etc/koko.yaml`. The default service port is `8888`, and the backend uses PostgreSQL.

```bash
cd server
make init
make migrate
go test ./...
go run koko.go -f etc/koko.yaml
```

The default development database settings can be overridden through `server/Makefile` variables:

```bash
make migrate host=127.0.0.1:5432 user=biroot pwd=123456 database=koko
```

## Development Workflow

### API changes

The backend uses go-zero `.api` files as the source of truth. When changing endpoints, routes, handler request types, or response types, update:

```text
server/doc/api/*.api
```

Then run from `server/`:

```bash
make api
```

Do not edit generated goctl files manually.

### Database changes

Database schema changes are managed through goose migrations. When changing tables or indexes, update:

```text
server/doc/migrations/*.sql
```

Then run migrations and regenerate models:

```bash
cd server
make migrate
make model-all
```

### iOS data source

The iOS app uses Mock services by default, which makes offline development, unit tests, and UI iteration straightforward. Once `KOUKOU_API_BASE_URL` is configured, the app switches to Remote services and calls the backend through `APIClient`.

## Verification

```bash
cd ios-app && ./scripts/verify.sh
cd server && go test ./...
git diff --check
```

If your machine does not have a compatible iOS Simulator runtime, `ios-app/scripts/verify.sh` may not be able to run the full test suite. In that case, use Xcode environment checks and Swift parsing checks first.

## API and Data Model

The backend API covers these modules:

- Auth: register, login, logout, and current user.
- Books: ledger list, detail, create, update, and archive.
- Members: member list, role update, and member removal.
- Invites: create invite, list invites, accept invite, and revoke invite.
- Categories: list, create, update, and archive categories.
- Transactions: list, create, detail, update, and delete transactions.
- Statistics: ledger summary, snapshots, trends, and category ratios.

The PostgreSQL schema includes `users`, `auth_sessions`, `books`, `book_members`, `book_invites`, `transaction_categories`, and `ledger_transactions`.

## Screenshots and Demo

Screenshots and demo assets are not included yet. The current focus is completing the iOS feature loop, backend API behavior, and local verification workflow.

## Contributing

Issues and pull requests are welcome. Before submitting changes, please try to:

- Keep changes focused and avoid unrelated formatting churn.
- Update `server/doc/api/*.api` before regenerating API code.
- Update `server/doc/migrations/*.sql` before regenerating database models.
- Run `cd ios-app && ./scripts/verify.sh` for iOS changes.
- Run `cd server && go test ./...` for backend changes.

## License

This project is open source under the [MIT License](./LICENSE).
