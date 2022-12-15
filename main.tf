terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.region
}

module "EC2" {
  source         = "./Module/EC2"
  ec2_key        = var.ec2_key
  region         = var.region
  company        = var.company
  vpc_id         = var.vpc_id
}

module "IAM_Master" {
  source = "./Module/IAM/Master"

  valohai_assume_user  = var.valohai_assume_user

  depends_on = [module.IAM_Workers]
}

module "IAM_Workers" {
  source = "./Module/IAM/Workers"
}

module "IAM_S3" {
  source = "./Module/IAM/S3"
}


module "S3" {
  source = "./Module/S3"

  depends_on = [module.IAM_S3]
}

