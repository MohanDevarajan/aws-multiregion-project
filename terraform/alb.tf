# Primary
resource "aws_lb" "primary" {
  name               = "${var.project_name}-${var.env}-alb-primary"
  load_balancer_type = "application"
  subnets            = module.vpc_primary.public_subnets
  security_groups    = [aws_security_group.alb_primary_sg.id]
}

resource "aws_lb_target_group" "primary" {
  name        = "${var.project_name}-${var.env}-tg-primary"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc_primary.vpc_id
  target_type = "ip"
  health_check { path = "/" }
}

resource "aws_lb_listener" "primary_http" {
  load_balancer_arn = aws_lb.primary.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary.arn
  }
}

resource "aws_ecs_service" "primary" {
  name            = "${var.project_name}-${var.env}-svc-primary"
  cluster         = aws_ecs_cluster.primary.arn
  task_definition = aws_ecs_task_definition.app_primary.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc_primary.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_primary_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.primary.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.primary_http]
}

# Secondary
resource "aws_lb" "secondary" {
  provider           = aws.secondary
  name               = "${var.project_name}-${var.env}-alb-secondary"
  load_balancer_type = "application"
  subnets            = module.vpc_secondary.public_subnets
  security_groups    = [aws_security_group.alb_secondary_sg.id]
}

resource "aws_lb_target_group" "secondary" {
  provider    = aws.secondary
  name        = "${var.project_name}-${var.env}-tg-secondary"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc_secondary.vpc_id
  target_type = "ip"
  health_check { path = "/" }
}

resource "aws_lb_listener" "secondary_http" {
  provider          = aws.secondary
  load_balancer_arn = aws_lb.secondary.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.secondary.arn
  }
}

resource "aws_ecs_service" "secondary" {
  provider        = aws.secondary
  name            = "${var.project_name}-${var.env}-svc-secondary"
  cluster         = aws_ecs_cluster.secondary.arn
  task_definition = aws_ecs_task_definition.app_secondary.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc_secondary.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_secondary_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.secondary.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.secondary_http]
}

# Staging (single region on primary VPC/SG)
resource "aws_lb" "staging" {
  name               = "${var.project_name}-${var.staging_env}-alb"
  load_balancer_type = "application"
  subnets            = module.vpc_primary.public_subnets
  security_groups    = [aws_security_group.alb_primary_sg.id]
}

resource "aws_lb_target_group" "staging" {
  name        = "${var.project_name}-${var.staging_env}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc_primary.vpc_id
  target_type = "ip"
  health_check { path = "/" }
}

resource "aws_lb_listener" "staging_http" {
  load_balancer_arn = aws_lb.staging.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging.arn
  }
}

resource "aws_ecs_service" "staging" {
  name            = "${var.project_name}-${var.staging_env}-svc"
  cluster         = aws_ecs_cluster.staging.arn
  task_definition = aws_ecs_task_definition.app_staging.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.vpc_primary.public_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_primary_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.staging.arn
    container_name   = "app"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.staging_http]
}