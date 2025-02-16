module "cloudrun" {
  source = "../../modules/cloudrun"

  project_id           = var.project_id
  project_number       = var.project_number
  region               = var.region
  langfuse_version     = var.langfuse_version
  nextauth_secret      = var.nextauth_secret
  salt                 = var.salt
  encryption_key       = var.encryption_key
  cloudsql_internal_ip = module.cloudsql.cloudsql_internal_ip
  vpc_network_name     = module.network.vpc_network_name

}

module "cloudsql" {
  source = "../../modules/cloudsql"

  project_id       = var.project_id
  region           = var.region
  vpc_network_name = module.network.vpc_network_name
}

module "network" {
  source = "../../modules/network"

  region = var.region
}