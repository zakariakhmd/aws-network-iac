output "instance_id" {
  description = "ID of the EC2 instance."
  value       = aws_instance.this.id
}

output "instance_name" {
  description = "Name tag of the EC2 instance."
  value       = aws_instance.this.tags["Name"]
}

output "private_ip" {
  description = "Private IP address of the EC2 instance."
  value       = aws_instance.this.private_ip
}

output "ami_id" {
  description = "AMI ID used for the instance."
  value       = local.ami_id
}
