# SNS topics must be regional. Create one per region and subscribe the same email.

# Primary region SNS
resource "aws_sns_topic" "alerts_primary" {
  name = "${var.project_name}-${var.env}-alerts-primary"
}

resource "aws_sns_topic_subscription" "alerts_primary_email" {
  topic_arn = aws_sns_topic.alerts_primary.arn
  protocol  = "email"
  endpoint  = var.sns_alert_email
}

# Secondary region SNS
resource "aws_sns_topic" "alerts_secondary" {
  provider = aws.secondary
  name     = "${var.project_name}-${var.env}-alerts-secondary"
}

resource "aws_sns_topic_subscription" "alerts_secondary_email" {
  provider  = aws.secondary
  topic_arn = aws_sns_topic.alerts_secondary.arn
  protocol  = "email"
  endpoint  = var.sns_alert_email
}

# CloudWatch alarms per region
resource "aws_cloudwatch_metric_alarm" "primary_high_cpu" {
  alarm_name          = "${var.project_name}-primary-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_sns_topic.alerts_primary.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.primary.name
    ServiceName = aws_ecs_service.primary.name
  }
}

resource "aws_cloudwatch_metric_alarm" "secondary_high_cpu" {
  provider            = aws.secondary
  alarm_name          = "${var.project_name}-secondary-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_sns_topic.alerts_secondary.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.secondary.name
    ServiceName = aws_ecs_service.secondary.name
  }
}
