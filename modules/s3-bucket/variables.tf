variable "bucket_name" {
  description = "Globally unique name of the S3 bucket."
  type        = string
}

variable "force_destroy" {
  description = "If true, the bucket (and its contents) can be destroyed by Terraform."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
