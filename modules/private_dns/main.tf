resource "azurerm_private_dns_zone" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# 指定した VNet ごとに Zone へリンクする（キーはリンク名の一部になる）
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.linked_vnet_ids

  name                  = "link-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = each.value
  registration_enabled  = false # 自動登録は不要（VM の名前は登録しない）
  tags                  = var.tags
}
