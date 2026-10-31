output "id" {
  description = "Managed Identity の リソース ID（VM への割り当てに使う）"
  value       = azurerm_user_assigned_identity.this.id
}

output "principal_id" {
  description = "ID の オブジェクト ID（ロール割り当てに使う）"
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "ID の クライアント ID（トークン取得時の指定に使う）"
  value       = azurerm_user_assigned_identity.this.client_id
}
