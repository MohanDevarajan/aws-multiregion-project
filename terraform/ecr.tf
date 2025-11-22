resource "aws_ecr_repository" "app_primary" {
  name                 = "${var.project_name}-${var.env}"
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_repository" "app_secondary" {
  provider             = aws.secondary
  name                 = "${var.project_name}-${var.env}"
  image_tag_mutability = "MUTABLE"
}
