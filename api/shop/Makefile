# =================================================================
# Tools for setting up the execution environment
# =================================================================
.PHONY: setup-env install-tools
setup-env: ## dev: Set environment variables
	@cp -p .env_sample .env
	@cp .env_localstack_sample .env_localstack

install-tools: setup-env ## dev: Install tools used in the project
	go install github.com/deepmap/oapi-codegen/cmd/oapi-codegen@latest
	go install golang.org/x/tools/cmd/godoc@latest
	go install github.com/rubenv/sql-migrate/...@latest
	go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
	go install go.uber.org/mock/mockgen@latest
	npm i -g @redocly/cli@latest


# =================================================================
# Generate Open API files and SQLC files
# =================================================================
.PHONY: gen-api bundle-openapi
gen-api: bundle-openapi ## dev: Generate API server interface and type definitions based on the Open API schema
	oapi-codegen -package gen -generate types -o internal/gen/types.gen.go ./spec/openapi.yaml
	oapi-codegen -package gen -generate strict-server,gin -templates ./spec/templates -o internal/gen/server.gen.go ./spec/openapi.yaml

bundle-openapi: ## dev: Bundle Open API files
	redocly bundle ./spec/openapi_base.yaml --output ./spec/openapi.yaml

gen-sqlc: ## dev: Generate SQLC files
	sqlc generate -f internal/repository/sqlc.yaml
	mockgen -source=./internal/repository/gen_sqlc/querier.go -package mock -destination=./internal/repository/gen_mock/mock_querier.go
	mockgen -source=./internal/repository/gen_sqlc/db.go -package mock -destination=./internal/repository/gen_mock/mock_db.go


# =================================================================
# Local execution environment setup
# =================================================================
.PHONY: lint deps build run
lint: ## dev: Static code analysis
	golangci-lint run --timeout 3m

deps: ## dev: Download dependencies
	go mod download && go mod tidy

build: deps ## dev: Build the project
	go build -o build/shop_api cmd/main.go

run: build ## dev: Run the project
	./build/shop_api


# =================================================================
# Container execution environment setup
# =================================================================
.PHONY: up down logs
up: ## dev: Start containers
	docker compose up -d shop-api mysql localstack

down: ## dev: Stop containers
	docker compose down shop-api mysql localstack

logs: ## dev: Show container logs
	docker compose logs -f shop-api


# =================================================================
# MySQL operations
# =================================================================
.PHONY: mysql
mysql: ## dev: Start MySQL container
	MYSQL_ROOT_PASSWORD=password#0 docker compose exec mysql mysql -u root -ppassword#0 -h localhost -P 33306 dev_core

# MySQL table migration
.PHONY: migrate-new migrate-up migrate-down migrate-status
migrate-new: ## dev: Create a new migration file
	sql-migrate new -env='dev' -config=./_tools/sql-migrate/config.yaml $(NAME)

migrate-up: ## dev: Apply migrations
	sql-migrate up -env='dev' -config=./_tools/sql-migrate/config.yaml

migrate-down: ## dev: Rollback migrations
	sql-migrate down -limit=1 -env='dev' -config=./_tools/sql-migrate/config.yaml

migrate-status: ## dev: Show migration status
	sql-migrate status -env='dev' -config=./_tools/sql-migrate/config.yaml


# =================================================================
# Scripts
# =================================================================
.PHONY: reset load
reset: ## dev/stg: Reset database data
	MYSQL_HOST=$(MYSQL_HOST) MYSQL_PORT=$(MYSQL_PORT) MYSQL_USER=$(MYSQL_USER) MYSQL_PASSWORD=$(MYSQL_PASSWORD) MYSQL_DATABASE=$(MYSQL_DATABASE) bash ./scripts/seeds/reset/reset.sh

load: reset ## dev/stg: Initialize database data
	MYSQL_HOST=$(MYSQL_HOST) MYSQL_PORT=$(MYSQL_PORT) MYSQL_USER=$(MYSQL_USER) MYSQL_PASSWORD=$(MYSQL_PASSWORD) MYSQL_DATABASE=$(MYSQL_DATABASE) bash ./scripts/seeds/loader/loader.sh

charge: load ## dev/stg: Initialize payment processing data
	MYSQL_HOST=$(MYSQL_HOST) MYSQL_PORT=$(MYSQL_PORT) MYSQL_USER=$(MYSQL_USER) MYSQL_PASSWORD=$(MYSQL_PASSWORD) MYSQL_DATABASE=$(MYSQL_DATABASE) go run ./scripts/seeds/charge/main.go

# for stg env
.PHONY: stg-migrate-up stg-migrate-down
stg-migrate-up: ## stg: Apply migrations
	mysql -h $(MYSQL_HOST) -P $(MYSQL_PORT) -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) < scripts/seeds/migrate/up.sql

stg-migrate-down: ## stg: Rollback migrations
	mysql -h $(MYSQL_HOST) -P $(MYSQL_PORT) -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) $(MYSQL_DATABASE) < scripts/seeds/migrate/down.sql


# =================================================================
# AWS resource operations
# =================================================================
VERSION := shop_api_v0.0.0

# ecr
.PHONY: auth push get-images delete-images
auth: ## stg: Authenticate ECR
	aws ecr get-login-password --region ap-northeast-1 --profile ${AWS_PROFILE} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com

push: auth ## stg: Push image to ECR
	docker build --platform linux/amd64 --no-cache -t $(AWS_ACCOUNT_ID).dkr.ecr.ap-northeast-1.amazonaws.com/stg-shop-api:$(VERSION) -f ./build/Dockerfile.shop .
	docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/stg-shop-api:$(VERSION)

get-images: ## stg: List images in ECR
	aws ecr list-images --repository-name stg-shop-api --region ap-northeast-1 --profile ${AWS_PROFILE} --query 'imageIds[*]' | jq .

delete-images: ## stg: Delete images in ECR
	@aws ecr list-images --repository-name stg-shop-api --region ap-northeast-1 --profile ${AWS_PROFILE} --query 'imageIds[*]' --output json > /tmp/images.json
	@cat /tmp/images.json | jq -c '.[]' | while read -r image_id; do \
		aws ecr batch-delete-image --repository-name stg-shop-api --region ap-northeast-1 --profile ${AWS_PROFILE} --image-ids $${image_id}; \
	done | jq .

# lambda
.PHONY: deploy
deploy: push ## stg: Deploy lambda function
	aws lambda update-function-code  --profile ${AWS_PROFILE} \
		--function-name stg-shop-api \
		--image-uri $(AWS_ACCOUNT_ID).dkr.ecr.ap-northeast-1.amazonaws.com/stg-shop-api:$(VERSION) | jq .

# ssm
.PHONY: ssm-start-session
ssm-start-session: ## stg: Start session
	aws ssm start-session --profile ${AWS_PROFILE} --region ap-northeast-1 --target $(TARGET_ID)

# secrets manager
.PHONY: dev-get-secret-list dev-get-secret-value stg-get-secret-value stg-force-delete-secret
dev-get-secret-list: ## dev: List secrets in Secrets Manager
	docker exec -it core-localstack awslocal secretsmanager list-secrets --region ap-northeast-1

dev-get-secret-value: ## dev: Get secrets from Secrets Manager
	docker exec -it core-localstack awslocal secretsmanager get-secret-value \
		--secret-id core/dev/rds-cluster \
		--region ap-northeast-1 | jq .

stg-get-secret-value: ## stg: Get secrets from Secrets Manager
	aws secretsmanager get-secret-value \
		--region ap-northeast-1 \
		--profile ${AWS_PROFILE} \
		--secret-id $(SECRET_ID) | jq .

stg-put-secret-value: ## stg: Update secrets in Secrets Manager
	aws secretsmanager put-secret-value \
		--profile ${AWS_PROFILE} \
		--secret-id $(SECRET_ID) \
		--secret-string "{\"dbname\":\"$(MYSQL_DATABASE)\",\"host\":\"$(MYSQL_HOST)\",\"port\":\"$(MYSQL_PORT)\",\"username\":\"$(MYSQL_USER)\",\"password\":\"$(MYSQL_PASSWORD)\"}" \
	| jq .

stg-force-delete-secret: ## stg: Force delete secrets in Secrets Manager
	aws secretsmanager delete-secret \
		--region ap-northeast-1 \
		--profile ${AWS_PROFILE} \
		--secret-id $(SECRET_ID) \
		--force-delete-without-recovery | jq .

# rds
.PHONY: stg-describe-db-instances stg-describe-db-proxy-targets
stg-describe-db-instances: ## stg: Get RDS information
	aws rds describe-db-instances --db-instance-identifier stg-data-pipeline-sample-core-db-instance-1 --profile ${AWS_PROFILE} --region ap-northeast-1 | jq .

stg-describe-db-proxy-targets: ## stg: Get RDS Proxy information
	aws rds describe-db-proxy-targets --profile ${AWS_PROFILE} --region ap-northeast-1 --db-proxy-name stg-data-pipeline-sample-core-db-proxy | jq .

# s3
S3_BUCKET_NAME ?= stg-data-pipeline-sample-glue-job-script
.PHONY: stg-s3-recursive-delete stg-s3-delete-versions stg-s3-delete-markers
stg-s3-recursive-delete: ## stg: Empty the Glue job script S3 bucket (remove all objects recursively)
	aws s3 rm s3://$(S3_BUCKET_NAME) \
		--profile ${AWS_PROFILE} --recursive

stg-s3-delete-versions:
	aws s3api delete-objects \
		--bucket $(S3_BUCKET_NAME) \
		--delete "$$(aws s3api list-object-versions \
			--bucket $(S3_BUCKET_NAME) \
			--profile ${AWS_PROFILE} \
			--query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
			--output json)" \
		--profile ${AWS_PROFILE} | jq .

stg-s3-delete-markers:
	aws s3api delete-objects \
		--bucket $(S3_BUCKET_NAME) \
		--delete "$$(aws s3api list-object-versions \
			--bucket $(S3_BUCKET_NAME) \
			--profile ${AWS_PROFILE} \
			--query='{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
			--output json)" \
		--profile ${AWS_PROFILE} | jq .


# =================================================================
# MySQL operations (port-forward, ping, cmd, dump, dump-import)
# =================================================================
# port forward
.PHONY: stg-core-port-forward stg-core-ping stg-core-cmd stg-core-dump stg-core-dump-import
stg-core-port-forward: ## stg: Port forward
	aws ssm start-session --profile ${AWS_PROFILE} --region ap-northeast-1 --target $(TARGET_ID) --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters host=$(DB_PROXY_HOST),portNumber="3306",localPortNumber="13306"

stg-core-ping: ## stg: Ping
	mysqladmin -h 127.0.0.1 -P 13306 -u core -ppassword ping

# cmd
stg-core-cmd: ## stg: Command
	mysql -h 127.0.0.1 -P 13306 -u core -ppassword stg_core -e "SELECT * FROM users WHERE id = '01975ff1-5ba9-73ca-be9a-75aa6bb00aaf';\G"

# dump
stg-core-dump: ## stg: Dump
	mysqldump -h 127.0.0.1 -P 13306 -u core -ppassword --quick --skip-lock-tables --no-autocommit --set-gtid-purged=OFF stg_core > $(DUMP_DIR)/stg_$(date +"%Y%m%d_%H%M%S").sql

# dump_import
stg-core-dump-import: ## stg: Dump import
	mysql -h 127.0.0.1 -P 33306 --local_infile=1 -u core -ppassword dev_core --init-command="SET autocommit=0;SET unique_checks=0;SET foreign_key_checks=0;" < $(DUMP_DIR)/stg_$(date +"%Y%m%d_%H%M%S").sql


# =================================================================
# API request operations (dev)
# =================================================================
ENV ?= dev

ifeq ($(ENV),dev)
	API_BASE_URL := http://localhost:8080
else ifeq ($(ENV),stg)
	API_BASE_URL := https://$(API_DOMAIN)
else ifeq ($(ENV),prd)
	API_BASE_URL := https://$(API_DOMAIN)
else
	$(error Invalid ENV specified: $(ENV))
endif

.PHONY: api-all-request
sleep: ## dev: Sleep for 0.1 seconds
	@sleep 0.1

api-all-request: healthcheck sleep \
	create-user sleep \
	get-me sleep \
	create-profile sleep \
	get-profile-me sleep \
	get-products sleep \
	get-product-by-id sleep \
	get-credit-cards sleep \
	create-credit-card sleep \
	delete-credit-card sleep \
	create-reservation sleep \
	create-charge sleep \
	get-charge-histories sleep \
	get-customer sleep \
	create-customer sleep \
	delete-customer sleep

stg-api-all-request: healthcheck sleep \
	create-user sleep \
	get-me sleep \
	create-reservation sleep \
	create-charge sleep

.PHONY: healthcheck
healthcheck: ## dev: healthcheck API request
	curl -i -X 'GET' \
		'${API_BASE_URL}/shop/v1/healthcheck' \
		-H 'accept: application/json'

# User API
.PHONY: create-user get-me create-profile get-profile-me
create-user: ## dev: Create user
	curl -i -X 'POST' \
		'${API_BASE_URL}/shop/v1/users' \
		-H 'accept: application/json' \
		-d ''

get-me: ## dev: Get user information
	curl -i -X 'GET' \
		'${API_BASE_URL}/shop/v1/users/me' \
		-H 'accept: application/json'

create-profile: ## dev: Create user profile
	curl -sX 'POST' \
		'${API_BASE_URL}/shop/v1/users/profiles' \
		-H 'accept: application/json' \
		-H 'Content-Type: application/json' \
		-d '{"name": {"first_name": "智","last_name": "真皿","first_name_roman": "Satoshi","last_name_roman": "Masara"}, "address": { "region": "関東", "zip_code": "150-8377", "prefecture": "東京都", "city": "渋谷区", "street": "宇田川町", "other": "15番1号"}, "birthdate": "2000-01-01", "image_url": "https://example"}' | jq .

get-profile-me: ## dev: Get user profile
	curl -sX 'GET' \
		'${API_BASE_URL}/shop/v1/users/profiles/me' \
		-H 'accept: application/json' | jq .

# Product API
.PHONY: get-products get-product-by-id
get-products: ## dev: Get product list
	curl -sX 'GET' \
		'${API_BASE_URL}/shop/v1/products?cursor=MjAwMDEwMDE%3D&limit=10' \
		-H 'accept: application/json' | jq .

get-product-by-id: ## dev: Get product details
	curl -sX 'GET' \
		'${API_BASE_URL}/shop/v1/products/10001002' \
		-H 'accept: application/json' | jq .

# External payment service customer information API
.PHONY: get-customer create-customer delete-customer
get-customer: ## dev: Get customer information
	curl -sX 'GET' \
		'${API_BASE_URL}/shop/v1/payment/customers/10001001' \
		-H 'accept: application/json' | jq .

create-customer: ## dev: Create customer
	curl -i -sX 'POST' \
		'${API_BASE_URL}/shop/v1/payment/customers' \
		-H 'accept: application/json' \
		-d ''

delete-customer: ## dev: Delete customer
	curl -i -sX 'DELETE' \
		'${API_BASE_URL}/shop/v1/payment/customers' \
		-H 'accept: */*'

# Card API
.PHONY: get-credit-cards create-credit-card delete-credit-card
get-credit-cards: ## dev: Get credit card list
	curl -sX 'GET' \
		'${API_BASE_URL}/shop/v1/payments/cards' \
		-H 'accept: application/json' | jq .

create-credit-card: ## dev: Create credit card
	curl -i -sX 'POST' \
		'${API_BASE_URL}/shop/v1/payments/cards' \
		-H 'accept: */*' \
		-H 'Content-Type: application/json' \
		-d '{"token": "9f9213b2-9687-6910-d2ec-3a247582be2d", "is_default": true}'

delete-credit-card: ## dev: Delete credit card
	curl -i -sX 'DELETE' \
		'${API_BASE_URL}/shop/v1/payments/cards' \
		-H 'accept: */*'

# Reservation API
.PHONY: create-reservation
create-reservation: ## dev: Create reservation
	curl -i -sX 'POST' \
		'${API_BASE_URL}/shop/v1/payments/reservations' \
		-H 'accept: application/json' \
		-H 'Content-Type: application/json' \
		-d '[{"product_id": 10001001, "quantity": 1}, {"product_id": 10001003, "quantity": 1}, {"product_id": 10001009, "quantity": 3}, {"product_id": 10001014, "quantity": 2}]'

# Charge API
.PHONY: create-charge get-charge-histories
# sample: make create-charge RESERVATION_ID=01976fe3-e429-7803-bfdc-fa4216f0c6b0
create-charge: ## dev: Create charge
	curl -i -sX 'POST' \
		'${API_BASE_URL}/shop/v1/payments/charges' \
		-H 'accept: application/json' \
		-H 'Content-Type: application/json' \
		-d '{"reservation_id": "$(RESERVATION_ID)"}'

get-charge-histories:
	curl -sX 'GET' \
		'${API_BASE_URL}/shop/v1/payments/charges/histories?offset=0&limit=10' \
		-H 'accept: application/json' | jq .


# =================================================================
# General
# =================================================================
.PHONY: help
help: ## Help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
