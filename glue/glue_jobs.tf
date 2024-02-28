variable "s3_bucket" {
    description = "The name of the S3 bucket to use for the Glue job"
    type        = string
}

variable "project" {
    description = "The name of the project"
    type        = string
}


variable "glue_service_role_arn" {
  type = string
}