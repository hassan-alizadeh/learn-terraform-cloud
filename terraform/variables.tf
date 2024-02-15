locals {
  glue_src_path = "${path.root}/../glue/"
}


variable "s3_bucket" {
#  type=string
  default = "startselect-da-glue-temp-dta"
}

variable "project" {
#  type=string
  default = "terraform_glue_job_deployment"
}
