locals {
  prefix = "obs-${var.environment}"
  tags = {
    environment = var.environment
    managed_by  = "terraform"
    purpose     = "observability"
  }
}

resource "azurerm_resource_group" "observability" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "${local.prefix}-law"
  location            = azurerm_resource_group.observability.location
  resource_group_name = azurerm_resource_group.observability.name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb
  tags                = local.tags
}

resource "azurerm_application_insights" "main" {
  name                = "${local.prefix}-appi"
  location            = azurerm_resource_group.observability.location
  resource_group_name = azurerm_resource_group.observability.name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  tags                = local.tags
}

resource "azurerm_monitor_workspace" "prometheus" {
  name                = "${local.prefix}-prom"
  location            = azurerm_resource_group.observability.location
  resource_group_name = azurerm_resource_group.observability.name
  tags                = local.tags
}

resource "azurerm_dashboard_grafana" "main" {
  name                              = "${local.prefix}-grafana"
  location                          = azurerm_resource_group.observability.location
  resource_group_name               = azurerm_resource_group.observability.name
  grafana_major_version             = "11"
  api_key_enabled                   = false
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true
  sku                               = "Standard"

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_monitor_data_collection_endpoint" "aks" {
  name                          = "${local.prefix}-dce"
  resource_group_name           = azurerm_resource_group.observability.name
  location                      = azurerm_resource_group.observability.location
  kind                          = "Linux"
  public_network_access_enabled = true
  tags                          = local.tags
}

resource "azurerm_monitor_action_group" "platform" {
  name                = "${local.prefix}-ag"
  resource_group_name = azurerm_resource_group.observability.name
  short_name          = "obs-alerts"

  email_receiver {
    name          = "platform-on-call"
    email_address = var.alert_email
  }

  tags = local.tags
}

resource "azurerm_role_assignment" "grafana_prometheus_reader" {
  scope                = azurerm_monitor_workspace.prometheus.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.main.identity[0].principal_id
}

resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "send-aks-control-plane-logs"
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category_group = "audit"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
