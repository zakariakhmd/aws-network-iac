output "subnet_ids" {
  description = "Map of subnet key => subnet ID."
  value       = { for k, s in aws_subnet.this : k => s.id }
}

output "subnet_ids_list" {
  description = "List of subnet IDs in this tier."
  value       = [for s in aws_subnet.this : s.id]
}

output "subnet_cidr_blocks" {
  description = "Map of subnet key => CIDR block."
  value       = { for k, s in aws_subnet.this : k => s.cidr_block }
}

output "route_table_id" {
  description = "ID of the route table associated with this tier."
  value       = aws_route_table.this.id
}
