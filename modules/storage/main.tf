resource "azurerm_storage_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  # セキュリティの基本設定
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false # 匿名アクセスを禁止

  # ファイアウォール：既定は拒否し、許可した接続元だけ通す
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = var.allowed_ip_addresses
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }
}

resource "azurerm_storage_container" "this" {
  for_each = toset(var.container_names)

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
