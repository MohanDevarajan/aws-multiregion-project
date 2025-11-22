# Primary ALB SG: allow inbound 80 from anywhere, outbound all
resource "aws_security_group" "alb_primary_sg" {
  name        = "${var.project_name}-${var.env}-alb-primary-sg"
  description = "ALB SG for primary region"
  vpc_id      = module.vpc_primary.vpc_id

  ingress {
    description      = "HTTP from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Primary ECS SG: allow container_port only from the ALB SG, outbound all
resource "aws_security_group" "ecs_primary_sg" {
  name        = "${var.project_name}-${var.env}-ecs-primary-sg"
  description = "ECS tasks SG for primary region"
  vpc_id      = module.vpc_primary.vpc_id

  ingress {
    description     = "From ALB to container port"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_primary_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Secondary ALB SG
resource "aws_security_group" "alb_secondary_sg" {
  provider    = aws.secondary
  name        = "${var.project_name}-${var.env}-alb-secondary-sg"
  description = "ALB SG for secondary region"
  vpc_id      = module.vpc_secondary.vpc_id

  ingress {
    description      = "HTTP from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Secondary ECS SG
resource "aws_security_group" "ecs_secondary_sg" {
  provider    = aws.secondary
  name        = "${var.project_name}-${var.env}-ecs-secondary-sg"
  description = "ECS tasks SG for secondary region"
  vpc_id      = module.vpc_secondary.vpc_id

  ingress {
    description     = "From ALB to container port"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_secondary_sg.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}