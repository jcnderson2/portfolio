output "law_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "law_workspace_id" {
  description = "Workspace (customer) ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}