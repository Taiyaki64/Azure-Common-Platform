output "id" {
  description = "Storage Account の ID"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Storage Account 名"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Blob サービスのエンドポイント URL"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}
