# deploy.tf

resource "aws_s3_object" "test_deploy_script_s3" {
  bucket = var.s3_bucket
  key = "glue/scripts/TestDeployScript/main.py"
  source = "${path.module}/main.py"
  etag = filemd5("${path.module}/main.py")
}

resource "aws_glue_job" "test_deploy_script" {
  name        = "TestDeployScript"
  description = "Test the deployment of an AWS Glue job to AWS Glue service with Terraform"
  role_arn    = aws_iam_role.glue_service_role.arn

  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${var.s3_bucket}/glue/scripts/TestDeployScript/main.py"
  }

  default_arguments = {
    "--additional-python-modules" = "awswrangler"
  }
}
