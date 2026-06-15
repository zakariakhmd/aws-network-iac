variable "project" {
  description = "Project name, used as part of resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
}

variable "region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-southeast-3"
}

variable "state_bucket" {
  description = "Name of the S3 bucket holding remote state (used to read the network layer's outputs)."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the backend instance."
  type        = string
}

variable "root_volume_size" {
  description = "Size of the EC2 root EBS volume in GiB."
  type        = number
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
}
