variable "name_prefix" {
  description = "Prefix applied to resource names and the Name tag."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the subnets belong to."
  type        = string
}

variable "tier" {
  description = "Logical tier name (e.g. public, private, data). Used for naming/tagging."
  type        = string
}

variable "subnets" {
  description = "Map of subnet definitions keyed by a short name (e.g. az-a)."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "map_public_ip_on_launch" {
  description = "Whether instances launched into these subnets receive a public IP."
  type        = bool
  default     = false
}

variable "create_internet_route" {
  description = "Whether to create a 0.0.0.0/0 route to the Internet Gateway."
  type        = bool
  default     = false
}

variable "internet_gateway_id" {
  description = "Internet Gateway used for the default route when create_internet_route is true."
  type        = string
  default     = null
}

variable "create_nat_route" {
  description = "Whether to create a 0.0.0.0/0 route to the NAT Gateway."
  type        = bool
  default     = false
}

variable "nat_gateway_id" {
  description = "NAT Gateway used for the default route when create_nat_route is true."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
