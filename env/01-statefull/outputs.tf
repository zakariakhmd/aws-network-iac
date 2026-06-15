output "instance_id" {
  description = "ID of the backend EC2 instance."
  value       = module.ec2.instance_id
}

output "instance_name" {
  description = "Name of the backend EC2 instance."
  value       = module.ec2.instance_name
}

output "instance_private_ip" {
  description = "Private IP address of the backend EC2 instance."
  value       = module.ec2.private_ip
}

output "iam_role_name" {
  description = "Name of the EC2 IAM role (the 02-data layer attaches its S3 policy here)."
  value       = module.iam_role.role_name
}

output "iam_role_arn" {
  description = "ARN of the EC2 IAM role."
  value       = module.iam_role.role_arn
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile."
  value       = module.iam_role.instance_profile_name
}

output "security_group_id" {
  description = "ID of the backend security group."
  value       = module.security_group.security_group_id
}

output "security_group_name" {
  description = "Name of the backend security group."
  value       = module.security_group.security_group_name
}
