output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = aws_nat_gateway.this.id
}

output "nat_eip_public_ip" {
  description = "Public Elastic IP address of the NAT Gateway."
  value       = aws_eip.this.public_ip
}
