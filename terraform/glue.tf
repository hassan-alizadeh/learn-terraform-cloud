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



# Generate modules for each Glue job folder
module "glue_jobs" {
  source = "../glue"  # Assuming the source directory for Glue job modules is "./glue"
#  for_each = toset(local.glue_job_folders) #{ for folder in local.glue_job_folders : folder => folder }

  # Passing necessary variables to the Glue job module

#      dynamic "content"{
#        for_each = toset(local.glue_job_folders)
#        content {
#          module_name = source.value
          s3_bucket = var.s3_bucket
          project = var.project
          glue_service_role_arn = aws_iam_role.glue_service_role.arn
#        }


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
