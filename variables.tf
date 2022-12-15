variable "aws_profile" {
  description = "AWS Profile name (~/.aws/credentials)"
  type        = string
}

variable "region" {
  description = "AWS region for Valohai resources"
  type        = string
}

variable "vpc_id" {
  description = "AWS VPC ID"
  type        = string
}

variable "company" {
  description = "Company name, used for Valohai resources"
  type        = string
}

variable "valohai_assume_user" {
    type = string
    description = "ARN of the user Valohai will use to assume the ValohaiMaster role in your account."
}