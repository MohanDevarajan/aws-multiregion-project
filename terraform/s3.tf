# -------------------------
# Primary Artifact Bucket
# -------------------------
resource "aws_s3_bucket" "artifact_primary" {
  bucket = "${var.project_name}-${var.env}-artifacts-${var.primary_region}"

  tags = {
    Name        = "${var.project_name}-artifacts-primary"
    Environment = var.env
  }
}

# Explicitly enforce bucket owner ownership (disables ACLs)
resource "aws_s3_bucket_ownership_controls" "artifact_primary_ownership" {
  bucket = aws_s3_bucket.artifact_primary.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "artifact_primary_versioning" {
  bucket = aws_s3_bucket.artifact_primary.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact_primary_encryption" {
  bucket = aws_s3_bucket.artifact_primary.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------
# Secondary Artifact Bucket
# -------------------------
resource "aws_s3_bucket" "artifact_secondary" {
  provider = aws.secondary
  bucket   = "${var.project_name}-${var.env}-artifacts-${var.secondary_region}"

  tags = {
    Name        = "${var.project_name}-artifacts-secondary"
    Environment = var.env
  }
}

resource "aws_s3_bucket_ownership_controls" "artifact_secondary_ownership" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.artifact_secondary.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "artifact_secondary_versioning" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.artifact_secondary.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact_secondary_encryption" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.artifact_secondary.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -------------------------
# IAM Role for Replication
# -------------------------
resource "aws_iam_role" "s3_replication" {
  name = "${var.project_name}-${var.env}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_replication_policy" {
  role = aws_iam_role.s3_replication.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication"
        ]
        Resource = [
          aws_s3_bucket.artifact_primary.arn,
          "${aws_s3_bucket.artifact_primary.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.artifact_secondary.arn,
          "${aws_s3_bucket.artifact_secondary.arn}/*"
        ]
      }
    ]
  })
}

# -------------------------
# Replication Configuration
# -------------------------
resource "aws_s3_bucket_replication_configuration" "artifact_replication" {
  bucket = aws_s3_bucket.artifact_primary.id
  role   = aws_iam_role.s3_replication.arn

  rule {
    id     = "replicate-artifacts"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.artifact_secondary.arn
      storage_class = "STANDARD"
    }
  }

  # ✅ Ensure versioning is applied before replication
  depends_on = [
    aws_s3_bucket_versioning.artifact_primary_versioning,
    aws_s3_bucket_versioning.artifact_secondary_versioning
  ]
}