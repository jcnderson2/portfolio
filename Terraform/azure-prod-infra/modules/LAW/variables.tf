variable "law_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "sku" {
  description = "The SKU of the Log Analytics Workspace"
  type        = string
  default     = "PerGB2018"
}

variable "retention_in_days" {
  description = "Retention period for logs (default 30 days)"
  type        = number
  default     = 30
}