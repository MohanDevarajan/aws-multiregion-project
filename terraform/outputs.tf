output "primary_alb_dns" { value = aws_lb.primary.dns_name }
output "secondary_alb_dns" { value = aws_lb.secondary.dns_name }
output "primary_ecr" { value = aws_ecr_repository.app_primary.repository_url }
output "secondary_ecr" { value = aws_ecr_repository.app_secondary.repository_url }
