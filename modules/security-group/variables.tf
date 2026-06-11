variable "name_prefix" {
  description = "Prefix applied to resource names and the Name tag."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the security group belongs to."
  type        = string
}

variable "description" {
  description = "Description of the security group."
  type        = string
  default     = "Egress-only security group (SSM access, no inbound)."
}

variable "tags" {
  description = "Common tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
