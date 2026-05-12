host ?= 127.0.0.1:5432
user ?= kroot
pwd ?= 123456
database ?= koko
table ?=
cache ?=
DEPLOY_IP = 43.135.51.230
REGISTRY_URL = crpi-q1ve3xes4w1b4677.cn-hongkong.personal.cr.aliyuncs.com/mdgame
app ?= server

.PHONY: init
# 初始化开发环境，安装依赖工具
init:
        go install github.com/zeromicro/go-zero/tools/goctl@latest
        goctl env check --install --verbose --force
        go install github.com/pressly/goose/v3/cmd/goose@latest

.PHONY: db
db:
        goctl model pg datasource --home=doc/tpl --url="postgres://${user}:${pwd}@${host}/${database}" -table="${table}" --dir internal/model --strict --style go_zero ${cache}

.PHONY: create-migration
create-migration:
        goose -dir ./doc/migrations create $(name) sql

.PHONY: migrate
migrate:
        @echo "Running migrations ..."
        goose -dir ./doc/migrations postgres "postgres://${user}:${pwd}@${host}/${database}" -allow-missing up

.PHONY: migrate-down
migrate-down:
        @echo "Running migrations down ..."
        goose -dir ./doc/migrations postgres "postgres://${user}:${pwd}@${host}/${database}" down

.PHONY: remote-migrate
# 更新远程数据库结构
remote-migrate:
        tar zvcf migrations.tar.gz doc/migrations
        scp migrations.tar.gz root@${DEPLOY_IP}:/root/workspace/
        ssh root@${DEPLOY_IP} "cd /root/workspace && rm -rf doc && tar zxvf migrations.tar.gz && rm -f migrations.tar.gz && rm -f doc/migrations/._* && make"
        rm -f migrations.tar.gz

.PHONY: api
# generate api code
api:
        goctl api format --dir ./server/doc/api/
        goctl api swagger -api ./server/doc/api/${app}.api -dir ./doc/swagger
        goctl api go --home=doc/tpl -api ./doc/api//${app}.api --dir ./server/${app}/ --type-group --style go_zero

.PHONY: build
# build exec file
build:
        mkdir -p bin/ && CGO_ENABLED=0 go build -ldflags="-s -w" -tags no_k8s -o ./bin/ ./...

.PHONY: img
# 构建Docker镜像
img:
        docker build -f service/${app}/Dockerfile --platform=linux/amd64 -t ${REGISTRY_URL}/bi-${app}:${tag} .

.PHONY: push
# 推送Docker镜像
push:
        docker push ${REGISTRY_URL}/bi-${app}:${tag}

.PHONY: update
# 更新服务器
update:
        ssh root@${DEPLOY_IP} "cd /dkroot/service/${app} && docker compose pull && docker compose up -d"
