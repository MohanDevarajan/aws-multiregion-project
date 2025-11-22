variable "project_name" {
  type = string
}

variable "primary_region" {
  type    = string
  default = "us-east-1"
}

variable "secondary_region" {
  type    = string
  default = "us-east-2"
}

variable "env" {
  type    = string
  default = "prod"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "desired_count" {
  type    = number
  default = 1
}

# Provide in terraform.tfvars
variable "sns_alert_email" {
  type = string
}

# GitHub v1 source settings
variable "github_owner" {
  type    = string
  default = "mohandevarajan"
}

variable "github_repo" {
  type    = string
  default = "aws_devops"
}

variable "github_branch" {
  type    = string
  default = "main"
}

# Store in terraform.tfvars (sensitive)
variable "github_oauth_token" {
  type      = string
  sensitive = true
}
