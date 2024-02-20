data "local_file" "glue_scripts" {
  depends_on = [local.glue_src_path]
  for_each   = fileset(local.glue_src_path, "**/*.py")

  filename = "${local.glue_src_path}/${each.key}"
}

locals {
  glue_jobs = {
    for filename, _ in data.local_file.glue_scripts : replace(filename, ".py", "") => {
      name        = replace(filename, ".py", "")
      script_key  = "glue/scripts/${filename}"
      script_path = filename
    }
  }
}

resource "aws_s3_object" "glue_job_scripts" {
  for_each = local.glue_jobs

  bucket = var.s3_bucket
  key    = each.value.script_key
  source = each.value.script_path
  etag   = filemd5(each.value.script_path)
}

resource "aws_glue_job" "glue_jobs" {
  for_each = local.glue_jobs

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

