locals {
  glue_jobs = [
    {
      name = "TestDeployScript1"
      script_key = "glue/scripts/TestDeployScript1.py"
      script_path = "${local.glue_src_path}TestDeployScript1.py"
    },
    {
      name = "TestDeployScript2"
      script_key = "glue/scripts/TestDeployScript2.py"
      script_path = "${local.glue_src_path}TestDeployScript2.py"
    }
    # Add more Glue job configurations as needed
  ]
}


resource "aws_s3_bucket_object" "glue_job_scripts" {
  for_each = { for job in local.glue_jobs : job.name => job }

  bucket = var.s3_bucket
  key    = each.value.script_key
  source = each.value.script_path
  etag   = filemd5(each.value.script_path)
}

resource "aws_glue_job" "glue_jobs" {
  for_each = { for job in local.glue_jobs : job.name => job }

  name        = each.value.name
  description = "Test the deployment of an AWS Glue job with Terraform"
  role_arn    = aws_iam_role.glue_service_role.arn

  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${var.s3_bucket}/${each.value.script_key}"
  }

  default_arguments = {
    "--additional-python-modules" = "awswrangler"
    "library-set"                  = "analytics"
  }

  tags = {
    project = var.project
  }
}
