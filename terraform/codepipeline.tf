# S3 artifact store
resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.project_name}-${var.env}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
}

# CodeBuild project
resource "aws_codebuild_project" "build" {
  name         = "${var.project_name}-${var.env}-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "PRIMARY_REGION"
      value = var.primary_region
    }
    environment_variable {
      name  = "SECONDARY_REGION"
      value = var.secondary_region
    }
    environment_variable {
      name  = "PROJECT_NAME"
      value = var.project_name
    }
    environment_variable {
      name  = "ENV"
      value = var.env
    }
    environment_variable {
      name  = "CONTAINER_PORT"
      value = tostring(var.container_port)
    }
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/${var.github_owner}/${var.github_repo}.git"
    buildspec = file("${path.module}/../ci/buildspec.yaml")
  }
}

# CodePipeline with GitHub v1 (OAuth token)
resource "aws_codepipeline" "pipeline" {
  name     = "${var.project_name}-${var.env}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "GitHubSource"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_out"]

      configuration = {
        Owner      = var.github_owner
        Repo       = var.github_repo
        Branch     = var.github_branch
        OAuthToken = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Build"
    action {
      name            = "CodeBuild"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_out"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }

  stage {
    name = "Approval"
    action {
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"

      configuration = {
        NotificationArn = aws_sns_topic.alerts_primary.arn
      }
    }
  }

  # Deploy via CodeBuild script (does ECS update-service in both regions)
  stage {
    name = "Deploy"
    action {
      name            = "DeployECS"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["source_out"]

      configuration = {
        ProjectName = aws_codebuild_project.build.name
      }
    }
  }
}
