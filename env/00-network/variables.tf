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

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones to spread subnets across."
  type        = number
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnet tier (one per AZ)."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnet tier (one per AZ)."
  type        = list(string)
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
}
