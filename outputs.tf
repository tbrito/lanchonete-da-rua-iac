output "rds2_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.lanchonetedarua3.address
  sensitive   = true
}

output "rds2_port" {
  description = "RDS instance port"
  value       = aws_db_instance.lanchonetedarua3.port
  sensitive   = true
}

output "rds2_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.lanchonetedarua3.username
  sensitive   = true
}
