# Terraform を実行する自分に、シークレットの読み書き権限を付与する。
# Key Vault（RBAC モデル）では、所有者でもこのロールがないとシークレットを作成できない
resource "azurerm_role_assignment" "me_kv_secrets_officer" {
  scope                = module.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
