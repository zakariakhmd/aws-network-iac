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
  description = "Name of the S3 bucket holding remote state (used to read the backend layer's outputs)."
  type        = string
  default     = "aws-network-iac-tfstate-changeme"
}

variable "bucket_name" {
  description = "Override for the data S3 bucket name. If null, a unique name is derived from project/environment/account ID."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "If true, the data bucket can be destroyed even when it contains objects."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
