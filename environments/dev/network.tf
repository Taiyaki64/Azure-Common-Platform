# Hub-VNet は Hub 環境（別 State）で作成済み。名前を指定して情報だけ読み取る
data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
}

module "peering" {
  source                    = "../../modules/vnet_peering"
  spoke_name                = "dev"
  spoke_resource_group_name = module.rg.name
  spoke_vnet_name           = module.vnet.name
  spoke_vnet_id             = module.vnet.id
  hub_resource_group_name   = var.hub_resource_group_name
  hub_vnet_name             = data.azurerm_virtual_network.hub.name
  hub_vnet_id               = data.azurerm_virtual_network.hub.id
}

# Hub に作成済みの Private DNS Zone を読み取る
data "azurerm_private_dns_zone" "this" {
  for_each = local.private_dns_zones

  name                = each.value
  resource_group_name = var.hub_resource_group_name
}

# Dev-VNet を Zone にリンクする（リンク自体は Zone と同じ Hub の Resource Group に作られる）
resource "azurerm_private_dns_zone_virtual_network_link" "dev" {
  for_each = local.private_dns_zones

  name                  = "link-dev-${each.key}"
  resource_group_name   = var.hub_resource_group_name
  private_dns_zone_name = data.azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = module.vnet.id
  registration_enabled  = false
  tags                  = local.common_tags
}

