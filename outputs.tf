output "rds2_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.lanchonetedarua2.address
  sensitive   = true
}

output "rds2_port" {
  description = "RDS instance port"
  value       = aws_db_instance.lanchonetedarua2.port
  sensitive   = true
}

output "rds2_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.lanchonetedarua2.username
  sensitive   = true
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = "${module.vpc.vpc_id}"
}