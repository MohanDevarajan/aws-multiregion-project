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
  default = "aws-multiregion-project"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "github_oauth_token" {
  type      = string
  sensitive = true
}

# ECS roles passed by CodePipeline for task execution/deploy
variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}