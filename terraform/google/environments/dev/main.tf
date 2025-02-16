locals {
  env_worker = {
    DATABASE_URL                                    = "postgresql://${module.postgres.postgres_user}:${module.postgres.postgres_password}@${module.postgres.cloudsql_internal_ip}/${module.postgres.postgres_db}"
    SALT                                            = var.salt
    ENCRYPTION_KEY                                  = var.encryption_key
    TELEMETRY_ENABLED                               = "true"
    CLICKHOUSE_URL                                  = "https://clickhouse-${var.project_number}.${var.region}.run.app:443"
    CLICKHOUSE_USER                                 = "clickhouse"
    CLICKHOUSE_PASSWORD                             = "clickhouse"
    CLICKHOUSE_CLUSTER_ENABLED                      = "false"
    LANGFUSE_S3_EVENT_UPLOAD_BUCKET                 = module.storage.bucket_name
    LANGFUSE_S3_EVENT_UPLOAD_REGION                 = var.region
    LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID          = module.storage.hmac_access_key_id
    LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY      = module.storage.hmac_secret_access_key
    LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT               = "https://storage.googleapis.com"
    LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE       = "true"
    LANGFUSE_S3_EVENT_UPLOAD_PREFIX                 = "events/"
    LANGFUSE_S3_MEDIA_UPLOAD_BUCKET                 = module.storage.bucket_name
    LANGFUSE_S3_MEDIA_UPLOAD_REGION                 = var.region
    LANGFUSE_S3_MEDIA_UPLOAD_ACCESS_KEY_ID          = module.storage.hmac_access_key_id
    LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY      = module.storage.hmac_secret_access_key
    LANGFUSE_S3_MEDIA_UPLOAD_ENDPOINT               = "https://storage.googleapis.com"
    LANGFUSE_S3_MEDIA_UPLOAD_FORCE_PATH_STYLE       = "true"
    LANGFUSE_S3_MEDIA_UPLOAD_PREFIX                 = "media/"
    LANGFUSE_INGESTION_QUEUE_DELAY_MS               = ""
    LANGFUSE_INGESTION_CLICKHOUSE_WRITE_INTERVAL_MS = ""
    REDIS_CONNECTION_STRING                         = "redis://default@${module.redis.redis_host}:${module.redis.redis_port}/0"
  }

  env_web = merge(local.env_worker, {
    NEXTAUTH_URL                          = "https://langfuse-web-${var.project_number}.${var.region}.run.app"
    NEXTAUTH_SECRET                       = var.nextauth_secret
    LANGFUSE_INIT_ORG_ID                  = ""
    LANGFUSE_INIT_ORG_NAME                = ""
    LANGFUSE_INIT_PROJECT_ID              = ""
    LANGFUSE_INIT_PROJECT_NAME            = ""
    LANGFUSE_INIT_PROJECT_PUBLIC_KEY      = ""
    LANGFUSE_INIT_PROJECT_SECRET_KEY      = ""
    LANGFUSE_INIT_USER_EMAIL              = ""
    LANGFUSE_INIT_USER_NAME               = ""
    LANGFUSE_INIT_USER_PASSWORD           = ""
  })
}

# At initial terraform apply, the following resource "web" should be commented out to avoid an error. After pushing the image to the artifact registry, uncomment the resource "web" and apply the terraform configuration again.
module "web" {
  source = "../../modules/web"

  project_id        = var.project_id
  region            = var.region
  web_repository_id = var.web_repository_id
  langfuse_version  = var.langfuse_version
  network_name      = module.vpc.network_name
  subnet_name       = module.vpc.subnet_name

  env_web = local.env_web

  depends_on = [ module.worker ]
}

module "worker" {
  source = "../../modules/worker"

  project_id              = var.project_id
  region                  = var.region
  worker_repository_id    = var.worker_repository_id
  langfuse_worker_version = var.langfuse_worker_version
  network_name            = module.vpc.network_name
  subnet_name             = module.vpc.subnet_name

  env_worker = local.env_worker

  depends_on = [ module.clickhouse ]
}


module "clickhouse" {
  source = "../../modules/clickhouse"

  project_id               = var.project_id
  region                   = var.region
  clickhouse_repository_id = var.clickhouse_repository_id
  clickhouse_version       = var.clickhouse_version
  network_name             = module.vpc.network_name
  subnet_name              = module.vpc.subnet_name

  env_clickhouse = {
    CLICKHOUSE_DB       = "default"
    CLICKHOUSE_USER     = "clickhouse"
    CLICKHOUSE_PASSWORD = "clickhouse"
  }
}

module "storage" {
  source = "../../modules/storage"

  project_id  = var.project_id
  region      = var.region
  bucket_name = var.bucket_name
}

module "redis" {
  source = "../../modules/redis"

  project_id   = var.project_id
  region       = var.region
  network_name = module.vpc.network_name
}

module "postgres" {
  source = "../../modules/postgres"

  project_id = var.project_id
  region     = var.region
  network_name = module.vpc.network_name

  env_postgres = {
    POSTGRES_USER     = "postgres"
    POSTGRES_PASSWORD = "postgres"
  }
}

module "regstry" {
  source = "../../modules/registry"

  project_id              = var.project_id
  region                  = var.region
  web_repository_id       = var.web_repository_id
  worker_repository_id    = var.worker_repository_id
  clickhouse_repository_id = var.clickhouse_repository_id
}


module "vpc" {
  source = "../../modules/vpc"

  region = var.region
}
