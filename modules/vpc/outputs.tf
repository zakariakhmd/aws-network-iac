output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_name" {
  description = "Name tag of the VPC."
  value       = aws_vpc.this.tags["Name"]
}

output "vpc_cidr_block" {
  description = "Primary CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}

output "internet_gateway_name" {
  description = "Name tag of the Internet Gateway."
  value       = aws_internet_gateway.this.tags["Name"]
}
