variable "module_name" {}
variable "module_source" {}
variable "s3_bucket" {}
variable "project" {}
variable "glue_service_role_arn" {}

module "glue_job" {
  source                = var.module_source
  s3_bucket            = var.s3_bucket
  project              = var.project
  glue_service_role_arn = var.glue_service_role_arn
}
