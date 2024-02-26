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

resource "aws_s3_object" "this" {
  bucket = var.s3_bucket
  key = "glue/job1/main.py"
  source = "glue/job1/main.py"
#  etag = filemd5("glue/job1/main.py")
}



# Define the Glue job resource
resource "aws_glue_job" "this" {
  name        = "job1"#var.job_name
  description = "Desc job1" #var.job_description
  role_arn    = var.glue_service_role_arn

  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${var.s3_bucket}/glue/job1/main.py"
  }

  default_arguments = {
    "--additional-python-modules" = "awswrangler"
    "library-set"                  = "analytics"
  }

  tags = {
    project = var.project
  }
}


output "output-job1-01" {
  value = var.project
}

output "output-job1-02" {
  value = var.s3_bucket
}

output "output-role_arn" {
  value = var.glue_service_role_arn
}