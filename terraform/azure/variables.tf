variable "resource_group_name" {
  description = "Resource group containing the observability resources."
  type        = string
}

variable "location" {
  description = "Azure region for observability resources."
  type        = string
  default     = "westus2"
}

variable "environment" {
  description = "Deployment environment label."
  type        = string
  default     = "portfolio"
}

variable "aks_cluster_id" {
  description = "Resource ID of the AKS cluster to monitor."
  type        = string
}

variable "alert_email" {
  description = "Email address used by the example action group."
  type        = string
  sensitive   = true
}

variable "log_retention_days" {
  description = "Log Analytics retention period."
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily Log Analytics ingestion cap."
  type        = number
  default     = 5
}
