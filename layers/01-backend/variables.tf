variable "project" {
  description = "Project name, used as part of resource naming."
  type        = string
  default     = "aws-network-iac"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket" {
  description = "Name of the S3 bucket holding remote state (used to read the network layer's outputs)."
  type        = string
  default     = "aws-network-iac-tfstate"
}

variable "instance_type" {
  description = "EC2 instance type for the backend instance."
  type        = string
  default     = "t2.micro"
}

variable "root_volume_size" {
  description = "Size of the EC2 root EBS volume in GiB."
  type        = number
  default     = 8
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
