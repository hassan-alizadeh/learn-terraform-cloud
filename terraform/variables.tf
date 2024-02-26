variable "aws_region" {
  description = "The AWS region where resources will be provisioned"
  default     = "eu-west-1"  # Set your desired default AWS region
}

variable "s3_bucket" {
  type    = string
  default = "startselect-da-glue-temp-dta"
}

variable "project" {
  type    = string
  default = "terraform_glue_job_deployment"
}


variable "module_path" {
  type    = string
  default = "/glue/"
}