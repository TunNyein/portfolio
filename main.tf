module "static_website" {
  source                     = "./modules/frontend"
  domain_name                = var.domain_name
  subject_alternative_names  = var.subject_alternative_names
  prefix                     = var.prefix
  environment                = var.environment
  dns_aliases                = var.dns_aliases
}

module "serverless" {
  source          = "./modules/backend"
  prefix          = var.prefix
  environment     = var.environment
  aws_region      = var.aws_region
  lambda_filename = "visitor_counter.zip"
}
