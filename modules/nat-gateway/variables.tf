variable "name_prefix" {
  description = "Prefix applied to resource names and the Name tag."
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet the NAT Gateway is placed in."
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
