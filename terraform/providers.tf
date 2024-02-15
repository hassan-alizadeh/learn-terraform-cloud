terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }

  required_version = "~> 1.2"
}


provider "aws" {
    region = "eu-west-1"  # Set your desired AWS region
#    profile = "default"
}


/*
terraform {
  backend "s3" {
    bucket = "adriano-data-uploads"
    key    = "terraform/terraform.tfstate"
    region = "ca-central-1"
    profile = "default"
  }
}*/
