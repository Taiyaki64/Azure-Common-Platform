output "id" {
  description = "Key Vault の ID"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "Key Vault 名"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "Key Vault の URI"
  value       = azurerm_key_vault.this.vault_uri
}
