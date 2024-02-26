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
#  module_path = var.module_path
#    job_name = "job1"
    /*job_role_arn = "arn:aws:iam::123456789012:role/service-role/AWSGlueServiceRole-DefaultRole"
    job_command_script_location = "s3://my-bucket/glue-scripts/job1.py"
    job_max_capacity = 2
    job_timeout = 60
    job_security_configuration = "my-security-configuration"
    job_notification_email = "*/
}

module "glue_job2" {
  source = "../glue/job2/"
  s3_bucket = var.s3_bucket
  project = var.project
  glue_service_role_arn = aws_iam_role.glue_service_role.arn
#  module_path = var.module_path
#    job_name = "job1"
    /*job_role_arn = "arn:aws:iam::123456789012:role/service-role/AWSGlueServiceRole-DefaultRole"
    job_command_script_location = "s3://my-bucket/glue-scripts/job1.py"
    job_max_capacity = 2
    job_timeout = 60
    job_security_configuration = "my-security-configuration"
    job_notification_email = "*/
}
