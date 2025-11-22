# -------------------------
# Primary ECR (Prod)
# -------------------------
resource "aws_ecr_repository" "app_primary" {
  name                 = "${var.project_name}-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# -------------------------
# Secondary ECR (Prod)
# -------------------------
resource "aws_ecr_repository" "app_secondary" {
  provider             = aws.secondary
  name                 = "${var.project_name}-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# -------------------------
# Primary ECR (Staging)
# -------------------------
resource "aws_ecr_repository" "app_staging_primary" {
  name                 = "${var.project_name}-${var.staging_env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# -------------------------
# Secondary ECR (Staging)
# -------------------------
resource "aws_ecr_repository" "app_staging_secondary" {
  provider             = aws.secondary
  name                 = "${var.project_name}-${var.staging_env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}