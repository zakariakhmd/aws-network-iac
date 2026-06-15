output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_name" {
  description = "Name of the VPC."
  value       = module.vpc.vpc_name
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC."
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway."
  value       = module.vpc.internet_gateway_id
}

output "internet_gateway_name" {
  description = "Name of the Internet Gateway."
  value       = module.vpc.internet_gateway_name
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = module.public_subnets.subnet_ids_list
}

output "public_subnet_names" {
  description = "List of public subnet names."
  value       = module.public_subnets.subnet_names_list
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = module.private_subnets.subnet_ids_list
}

output "private_subnet_names" {
  description = "List of private subnet names."
  value       = module.private_subnets.subnet_names_list
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = module.public_subnets.route_table_id
}

output "public_route_table_name" {
  description = "Name of the public route table."
  value       = module.public_subnets.route_table_name
}

output "private_route_table_id" {
  description = "ID of the private route table."
  value       = module.private_subnets.route_table_id
}

output "private_route_table_name" {
  description = "Name of the private route table."
  value       = module.private_subnets.route_table_name
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = module.nat_gateway.nat_gateway_id
}

output "nat_gateway_name" {
  description = "Name of the NAT Gateway."
  value       = module.nat_gateway.nat_gateway_name
}

output "nat_eip_public_ip" {
  description = "Public Elastic IP of the NAT Gateway."
  value       = module.nat_gateway.nat_eip_public_ip
}

output "nat_eip_name" {
  description = "Name of the NAT Gateway Elastic IP."
  value       = module.nat_gateway.nat_eip_name
}
