output "bucket_id" {
  description = "Name (ID) of the data S3 bucket."
  value       = module.s3_bucket.bucket_id
}

output "bucket_arn" {
  description = "ARN of the data S3 bucket."
  value       = module.s3_bucket.bucket_arn
}

output "ec2_s3_access_policy_arn" {
  description = "ARN of the least-privilege S3 access policy attached to the EC2 role."
  value       = aws_iam_policy.ec2_s3_access.arn
}
