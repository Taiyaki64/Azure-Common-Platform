data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.tags

  # アクセス制御は RBAC で行う（アクセスポリシーは使わない）
  rbac_authorization_enabled = true

  # 誤削除対策。削除しても 7 日間は復元できる（学習用なので Purge Protection は無効）
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # ファイアウォール：既定は拒否し、許可した接続元だけ通す
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_addresses
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }
}