# Existing clusters
resource "aws_ecs_cluster" "primary" {
  name = "${var.project_name}-${var.env}-cluster-primary"
}

resource "aws_ecs_cluster" "secondary" {
  provider = aws.secondary
  name     = "${var.project_name}-${var.env}-cluster-secondary"
}

# Staging cluster (single-region on primary)
resource "aws_ecs_cluster" "staging" {
  name = "${var.project_name}-${var.staging_env}-cluster"
}

# Log groups
resource "aws_cloudwatch_log_group" "app_primary" {
  name              = "/ecs/${var.project_name}-${var.env}-primary"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "app_secondary" {
  provider          = aws.secondary
  name              = "/ecs/${var.project_name}-${var.env}-secondary"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "app_staging" {
  name              = "/ecs/${var.project_name}-${var.staging_env}"
  retention_in_days = 7
}

# Task definitions
resource "aws_ecs_task_definition" "app_primary" {
  family                   = "${var.project_name}-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "app"
      image        = aws_ecr_repository.app_primary.repository_url
      essential    = true
      portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app_primary.name
          awslogs-region        = var.primary_region
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "app_secondary" {
  provider                 = aws.secondary
  family                   = "${var.project_name}-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "app"
      image        = aws_ecr_repository.app_secondary.repository_url
      essential    = true
      portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app_secondary.name
          awslogs-region        = var.secondary_region
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}

# Staging task definition (uses primary ECR image)
resource "aws_ecs_task_definition" "app_staging" {
  family                   = "${var.project_name}-${var.staging_env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = "app"
      image        = aws_ecr_repository.app_primary.repository_url
      essential    = true
      portMappings = [{ containerPort = var.container_port, protocol = "tcp" }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app_staging.name
          awslogs-region        = var.primary_region
          awslogs-stream-prefix = "app"
        }
      }
    }
  ])
}