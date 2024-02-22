# deploy.tf

# Define the Glue job resource
resource "aws_glue_job" "this" {
  name        = var.job_name
  description = var.job_description
  role_arn    = aws_iam_role.glue_service_role.arn

  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${var.s3_bucket}/${var.job_name}/${var.script_key}"
  }

  default_arguments = {
    "--additional-python-modules" = "awswrangler"
    "library-set"                  = "analytics"
  }

  tags = {
    project = var.project
  }
}
