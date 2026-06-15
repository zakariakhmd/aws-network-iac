output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = aws_nat_gateway.this.id
}

output "nat_gateway_name" {
  description = "Name tag of the NAT Gateway."
  value       = aws_nat_gateway.this.tags["Name"]
}

output "nat_eip_public_ip" {
  description = "Public Elastic IP address of the NAT Gateway."
  value       = aws_eip.this.public_ip
}

output "nat_eip_name" {
  description = "Name tag of the NAT Gateway Elastic IP."
  value       = aws_eip.this.tags["Name"]
}
