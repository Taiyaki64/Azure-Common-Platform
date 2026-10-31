# Terraform を実行する自分に、シークレットの読み書き権限を付与する。
# Key Vault（RBAC モデル）では、所有者でもこのロールがないとシークレットを作成できない
resource "azurerm_role_assignment" "me_kv_secrets_officer" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# ① VM（の Managed Identity）に、Key Vault のシークレット読み取り権限を付与
resource "azurerm_role_assignment" "vm_kv_secrets_user" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.managed_identity.principal_id

  # 作成直後の ID は Entra ID への反映が遅れることがあるため、存在確認をスキップする
  skip_service_principal_aad_check = true
}

# ② VM（の Managed Identity）に、Storage の Blob 読み書き権限を付与
resource "azurerm_role_assignment" "vm_storage_blob_contributor" {
  scope                = module.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.managed_identity.principal_id

  skip_service_principal_aad_check = true
}
