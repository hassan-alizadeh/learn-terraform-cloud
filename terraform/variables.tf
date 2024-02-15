locals {
  glue_src_path = "${path.root}/../glue/"
}

variable "s3_bucket" {
  type=string
  s3_bucket = "startselect-da-glue-temp-dta"
}

variable "project" {
  type=string
  project = "terraform_glue_job_deployment"
}