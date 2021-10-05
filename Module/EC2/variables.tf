variable "ec2_key" {
  description = "Location of the queue ssh key pub file"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "company" {
  description = "Company"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for queue"
  type        = string
}

variable "subnet" {
  description = "Valohai subnet to use for queue"
  type        = string
}

variable "security_group" {
  description = "AWS SG to use for queue"
  type        = string
}

variable "queue_address" {
  type        = string
}
