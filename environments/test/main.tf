terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-acp-tfstate-jpe-001"
    storage_account_name = "stacptfstate55814" # Step7 で作成した State 用ストレージ名
    container_name       = "tfstate"
    key                  = "test.terraform.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Hub-VNet は Hub 環境（別 State）で作成済み。名前を指定して情報だけ読み取る
data "azurerm_virtual_network" "hub" {
  name                = var.hub_vnet_name
  resource_group_name = var.hub_resource_group_name
}

module "rg" {
  source   = "../../modules/rg"
  name     = "rg-acp-test-jpe-001"
  location = var.location
  tags     = local.common_tags
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = "vnet-acp-test-jpe-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  address_space       = ["10.2.0.0/16"]
  tags                = local.common_tags
}

module "subnet_app" {
  source               = "../../modules/subnet"
  name                 = "snet-acp-test-app-001"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

module "peering" {
  source                    = "../../modules/vnet_peering"
  spoke_name                = "test"
  spoke_resource_group_name = module.rg.name
  spoke_vnet_name           = module.vnet.name
  spoke_vnet_id             = module.vnet.id
  hub_resource_group_name   = var.hub_resource_group_name
  hub_vnet_name             = data.azurerm_virtual_network.hub.name
  hub_vnet_id               = data.azurerm_virtual_network.hub.id
}
