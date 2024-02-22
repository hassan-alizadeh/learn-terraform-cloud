#glue.tf
# glue.tf

locals {
  glue_job_folders = fileset(path.root, "../glue/*")
}

# Iterate over all Glue job folders and include their deploy.tf files
locals {
  glue_job_configs = merge([
    for folder in local.glue_job_folders :
    try(
      yamldecode(file("${folder}/deploy.tf")),
      {}
    )
  ]...)
}

resource "aws_s3_bucket_object" "glue_job_scripts" {
  for_each = { for job, config in local.glue_job_configs : job => config }

  bucket = var.s3_bucket
  key    = "${job}/${each.value.script_key}"
  source = "${job}/${each.value.script_path}"
  etag   = filemd5("${job}/${each.value.script_path}")
}

resource "aws_glue_job" "glue_jobs" {
  for_each = { for job, config in local.glue_job_configs : job => config }

  name        = each.value.name
  description = each.value.description
  role_arn    = aws_iam_role.glue_service_role.arn

  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${var.s3_bucket}/${job}/${each.value.script_key}"
  }

  default_arguments = {
    "--additional-python-modules" = "awswrangler"
    "library-set"                  = "analytics"
  }

  tags = {
    project = var.project
  }
}
