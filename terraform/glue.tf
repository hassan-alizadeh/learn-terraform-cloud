#glue.tf

locals {
  glue_job_folders = [for dir in fileset(path.module, "../glue/**/*.tf"): dirname(dir)]
  glue_job_conf_files = fileset(path.root, "../glue/**/*.tf")
}

output "glue_job_folders_output" {
  value = local.glue_job_folders
}

output "glue_service_role_arn" {
  value = aws_iam_role.glue_service_role.arn
}
/*

module "glue_job1" {
  source = "../glue/job1/"
  s3_bucket = var.s3_bucket
  project = var.project
  glue_service_role_arn = aws_iam_role.glue_service_role.arn
}

module "glue_job2" {
  source = "../glue/job2/"
  s3_bucket = var.s3_bucket
  project = var.project
  glue_service_role_arn = aws_iam_role.glue_service_role.arn
}
*/

locals {
  module_configurations = [
    {
      module_name          = "glue_job1"
      module_source        = "../glue/job1/"
      s3_bucket            = var.s3_bucket
      project              = var.project
      glue_service_role_arn = aws_iam_role.glue_service_role.arn
    },
    {
      module_name          = "glue_job2"
      module_source        = "../glue/job2/"
      s3_bucket            = var.s3_bucket
      project              = var.project
      glue_service_role_arn = aws_iam_role.glue_service_role.arn
    }
    // Add more module configurations as needed
  ]
}

dynamic "module" {
  for_each = { for cfg in local.module_configurations : cfg.module_name => cfg }

  content {
    source               = module.value.module_source
    s3_bucket            = module.value.s3_bucket
    project              = module.value.project
    glue_service_role_arn = module.value.glue_service_role_arn
  }
}
