variable "aws_region" {
  description = "AWS region for observability resources."
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Deployment environment label."
  type        = string
  default     = "portfolio"
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster to observe."
  type        = string
}

variable "alert_email" {
  description = "Email endpoint for the example SNS alert subscription."
  type        = string
  sensitive   = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period."
  type        = number
  default     = 30
}
