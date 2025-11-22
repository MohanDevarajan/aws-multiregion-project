# -------------------------
# ALB DNS Outputs
# -------------------------
output "primary_alb_dns" {
  description = "DNS name of the primary ALB (prod)"
  value       = aws_lb.primary.dns_name
}

output "secondary_alb_dns" {
  description = "DNS name of the secondary ALB (prod)"
  value       = aws_lb.secondary.dns_name
}

output "staging_alb_dns" {
  description = "DNS name of the staging ALB"
  value       = aws_lb.staging.dns_name
}

# -------------------------
# ECR Repo URLs
# -------------------------
output "primary_ecr" {
  description = "ECR repo URL in primary region (prod)"
  value       = aws_ecr_repository.app_primary.repository_url
}

output "secondary_ecr" {
  description = "ECR repo URL in secondary region (prod)"
  value       = aws_ecr_repository.app_secondary.repository_url
}

output "staging_ecr_primary" {
  description = "ECR repo URL in primary region (staging)"
  value       = aws_ecr_repository.app_staging_primary.repository_url
}

output "staging_ecr_secondary" {
  description = "ECR repo URL in secondary region (staging)"
  value       = aws_ecr_repository.app_staging_secondary.repository_url
}