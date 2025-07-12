## env: local

Prerequisites:
- Since the MySQL DB is created with docker compose, the following steps assume that is already done.
- For the dev environment, schema management is handled using the Go-based tool sql-migrate.

```bash
# Run migration
$ make migrate-up

# Seed initial data
$ make charge MYSQL_HOST=localhost MYSQL_PORT=33306 MYSQL_USER=root MYSQL_PASSWORD=password#0 MYSQL_DATABASE=dev_core
```

## env: stg

1. Status Check
```bash
# Check RDS instance status
$ make stg-describe-db-instances AWS_PROFILE=$(AWS_PROFILE)

# Check RDS Proxy status
$ make stg-describe-db-proxy-targets AWS_PROFILE=$(AWS_PROFILE)
```

2. Operations on Bastion Server
```bash
# Access bastion via SSM
$ make ssm-start-session AWS_PROFILE=$(AWS_PROFILE) TARGET_ID=$(TARGET_ID)

# Set Go path
$ export PATH=$PATH:/usr/local/go/bin

# Create directories required for Go script execution and assign permissions
$ sudo mkdir -p /home/ssm-user/go /home/ssm-user/.cache
$ sudo chown -R ssm-user:ssm-user /home/ssm-user/go
$ sudo chown -R ssm-user:ssm-user /home/ssm-user/.cache

# Move to project root directory
$ cd /home/ssm-user/workspace/kinesis_platform_sample/api/shop/

# Run migration
$ make stg-migrate-up MYSQL_HOST=$(RDS_PROXY_HOST_NAME) MYSQL_PORT=3306 MYSQL_USER=core MYSQL_PASSWORD='password' MYSQL_DATABASE=stg_core

# Seed initial data
$ make charge MYSQL_HOST=$(RDS_PROXY_HOST_NAME) MYSQL_PORT=3306 MYSQL_USER=core MYSQL_PASSWORD='password' MYSQL_DATABASE=stg_core

# Access DB via RDS Proxy
$ mysql -h $(RDS_PROXY_HOST_NAME) -P 3306 -u core -ppassword -D stg_core
```

4. Update Secrets Manager `host` (This needs to be executed before using the service since the host name is set to a dummy value when creating the Secrets Manager)
```bash
# Update
$ make stg-put-secret-value AWS_PROFILE=xxxxxxxxxxxx SECRET_ID=kinesis-platform-sample/stg/shop/core/rds-cluster MYSQL_DATABASE=stg_core MYSQL_HOST=xxxxxxxxxxxx MYSQL_PORT=3306 MYSQL_USER=core MYSQL_PASSWORD=password

# Verify
$ make stg-get-secret-value AWS_PROFILE=xxxxxxxxxxxx SECRET_ID=kinesis-platform-sample/stg/shop/core/rds-cluster
```
