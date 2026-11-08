output "id" {
  description = "ワークスペースの ID（DCR や診断設定の送り先に使う）"
  value       = azurerm_log_analytics_workspace.this.id
}

output "name" {
  description = "ワークスペース名"
  value       = azurerm_log_analytics_workspace.this.name
}
