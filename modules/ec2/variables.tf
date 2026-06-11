variable "name_prefix" {
  description = "Prefix applied to resource names and the Name tag."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use. If null, the latest Amazon Linux 2023 AMI is resolved automatically."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID of the (private) subnet to launch the instance into."
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the instance."
  type        = list(string)
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile to attach (provides SSM + S3 access)."
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB."
  type        = number
  default     = 8
}

variable "tags" {
  description = "Common tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
