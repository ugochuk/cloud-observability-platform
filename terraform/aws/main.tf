data "aws_caller_identity" "current" {}

locals {
  prefix = "obs-${var.environment}"
  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Observability"
  }
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/platform/${var.environment}/checkout-api"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "otel_collector" {
  name              = "/platform/${var.environment}/otel-collector"
  retention_in_days = var.log_retention_days
}

resource "aws_prometheus_workspace" "main" {
  alias = "${local.prefix}-amp"
}

resource "aws_grafana_workspace" "main" {
  name                     = "${local.prefix}-grafana"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  notification_destinations = ["SNS"]
}

resource "aws_sns_topic" "platform_alerts" {
  name = "${local.prefix}-platform-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.platform_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "api_high_5xx" {
  alarm_name          = "${local.prefix}-checkout-api-high-5xx"
  alarm_description   = "Checkout API 5xx count is above the reviewed threshold. See the linked runbook in the repository."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm  = 2
  metric_name          = "5XXError"
  namespace            = "CloudObservabilityPortfolio"
  period               = 300
  statistic            = "Sum"
  threshold            = 5
  treat_missing_data   = "notBreaching"
  alarm_actions        = [aws_sns_topic.platform_alerts.arn]
  ok_actions           = [aws_sns_topic.platform_alerts.arn]

  dimensions = {
    Cluster = var.eks_cluster_name
    Service = "checkout-api"
  }
}

resource "aws_cloudwatch_metric_alarm" "api_high_latency" {
  alarm_name          = "${local.prefix}-checkout-api-high-latency"
  alarm_description   = "Checkout API p95 latency exceeds 500 milliseconds."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  datapoints_to_alarm  = 2
  metric_name          = "LatencyP95"
  namespace            = "CloudObservabilityPortfolio"
  period               = 300
  statistic            = "Average"
  threshold            = 500
  unit                 = "Milliseconds"
  treat_missing_data   = "notBreaching"
  alarm_actions        = [aws_sns_topic.platform_alerts.arn]

  dimensions = {
    Cluster = var.eks_cluster_name
    Service = "checkout-api"
  }
}

resource "aws_cloudwatch_dashboard" "service_overview" {
  dashboard_name = "${local.prefix}-checkout-api"
  dashboard_body = templatefile("${path.module}/../../dashboards/aws-cloudwatch.json.tftpl", {
    aws_region  = var.aws_region
    cluster     = var.eks_cluster_name
    log_group   = aws_cloudwatch_log_group.application.name
  })
}

resource "aws_xray_group" "checkout_api" {
  group_name        = "${local.prefix}-checkout-api"
  filter_expression = "service(\"checkout-api\")"

  insights_configuration {
    insights_enabled      = true
    notifications_enabled = true
  }
}
