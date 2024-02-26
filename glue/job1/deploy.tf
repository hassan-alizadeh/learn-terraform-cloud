# deploy.tf


resource "aws_s3_object" "this" {
  bucket = var.s3_bucket
  key = "glue/job1/main.py"
  source = "main.py"
  etag = filemd5("main.py")
}

# Define the Glue job resource
resource "aws_glue_job" "this" {
  name        = "job1"#var.job_name
  description = "Desc job1" #var.job_description
  role_arn    = aws_iam_role.glue_service_role.arn

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
