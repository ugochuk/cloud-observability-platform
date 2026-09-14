output "prometheus_remote_write_endpoint" {
  value = aws_prometheus_workspace.main.prometheus_endpoint
}

output "grafana_endpoint" {
  value = aws_grafana_workspace.main.endpoint
}

output "platform_alerts_topic_arn" {
  value = aws_sns_topic.platform_alerts.arn
}

output "application_log_group" {
  value = aws_cloudwatch_log_group.application.name
}
