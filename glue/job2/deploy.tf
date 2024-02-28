# deploy.tf

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


locals {
  module_name = basename(path.module)
}

output "module_name" {
  value = local.module_name
}

resource "aws_s3_object" "this" {
  bucket = var.s3_bucket
  key = "glue/${local.module_name}/main.py"
  source = "../glue/${local.module_name}/main.py"
#  etag = filemd5("glue/${local.module_name}/main.py")
}

# Define the Glue job resource
resource "aws_glue_job" "this" {
  name        = local.module_name
  description = "Desc job1"
  role_arn    = var.glue_service_role_arn

  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${var.s3_bucket}/glue/${local.module_name}/main.py"
  }

  default_arguments = {
    "--additional-python-modules" = "awswrangler"
    "library-set"                  = "analytics"
  }

  tags = {
    project = var.project
  }
}

