output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.main.id
}

output "application_insights_connection_string" {
  value     = azurerm_application_insights.main.connection_string
  sensitive = true
}

output "prometheus_workspace_id" {
  value = azurerm_monitor_workspace.prometheus.id
}

output "grafana_endpoint" {
  value = azurerm_dashboard_grafana.main.endpoint
}

output "action_group_id" {
  value = azurerm_monitor_action_group.platform.id
}
