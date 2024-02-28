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

output "module_glue_job1" {
  value = [module.glue_job1.module_name, module.glue_job2.module_name]
}




# Dynamically call each module existing within the directory "../glue/"





/*

module "glue_jobs" {
  source = "../glue/glue_jobs/"

  for_each = {
    for folder in local.glue_job_folders : folder => folder... #"../glue/${folder}/"
  }

  module_name          = each.key
  module_source        = each.value
  s3_bucket            = var.s3_bucket
  project              = var.project
  glue_service_role_arn = aws_iam_role.glue_service_role.arn
}
*/
