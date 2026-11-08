terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Hub 専用の State（Dev とは別ファイルにして、互いの作業が影響しないようにする）
  backend "azurerm" {
    resource_group_name  = "rg-acp-tfstate-jpe-001"
    storage_account_name = "stacptfstate55814" # Step7 で作成した State 用ストレージ名
    container_name       = "tfstate"
    key                  = "hub.terraform.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {
    log_analytics_workspace {
      # destroy 時にワークスペースを完全削除する。
      # これがないと、論理削除（14 日間）の間は同じ名前で再作成できず、学習中の再構築で詰まる
      permanently_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

module "rg" {
  source   = "../../modules/rg"
  name     = "rg-acp-hub-jpe-001"
  location = var.location
  tags     = local.common_tags
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = "vnet-acp-hub-jpe-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

# 将来の共通サービス（DNS Resolver など）用。今はリソースを置かない
module "subnet_shared" {
  source               = "../../modules/subnet"
  name                 = "snet-acp-hub-shared-001"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "private_dns" {
  source   = "../../modules/private_dns"
  for_each = local.private_dns_zones

  name                = each.value
  resource_group_name = module.rg.name
  tags                = local.common_tags

  # Hub-VNet 自身をリンク。Dev / Test のリンクは、それぞれの環境側で追加する
  linked_vnet_ids = {
    hub = module.vnet.id
  }
}

module "log_analytics" {
  source              = "../../modules/log_analytics"
  name                = "log-acp-hub-jpe-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  retention_in_days   = 30
  daily_quota_gb      = 0.5
  tags                = local.common_tags
}

