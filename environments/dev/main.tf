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
    storage_account_name = "stacptfstate55814"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    use_azuread_auth     = true
  }
}

# 現在 Terraform を実行しているユーザーの情報（ロール割り当てで使う）
data "azurerm_client_config" "current" {}

provider "azurerm" {
  features {
    key_vault {
      # destroy 時に論理削除（ソフトデリート）状態の Key Vault も完全削除する。
      # これがないと、同じ名前で再作成できず（名前が 7 日間予約される）、学習中の再構築で詰まる
      purge_soft_delete_on_destroy = true
    }
  }
  subscription_id = var.subscription_id
}

module "rg" {
  source   = "../../modules/rg"
  name     = "rg-acp-dev-jpe-001"
  location = var.location
  tags     = local.common_tags
}

module "vnet" {
  source              = "../../modules/vnet"
  name                = "vnet-acp-dev-jpe-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  address_space       = ["10.1.0.0/16"]
  tags                = local.common_tags
}

module "subnet_app" {
  source               = "../../modules/subnet"
  name                 = "snet-acp-dev-app-001"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"] # 追加
}

# （module "nsg_app" / module "vm" は変更なし）

module "storage" {
  source              = "../../modules/storage"
  name                = "stacpdevjpe001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  tags                = local.common_tags

  # 自宅 IP（Terraform を実行する PC）と app Subnet（VM）のみ許可。
  # ip_rules には /32 を付けられないため取り除く
  allowed_ip_addresses = [trimsuffix(var.allowed_ssh_source_ip, "/32")]
  allowed_subnet_ids   = [module.subnet_app.id]
  container_names      = ["app-data"]
}


module "nsg_app" {
  source              = "../../modules/nsg"
  name                = "nsg-acp-dev-app-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.subnet_app.id
  tags                = local.common_tags

  security_rules = [
    {
      name                   = "Allow-SSH-From-MyIP"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "22"
      source_address_prefix  = var.allowed_ssh_source_ip
    }
  ]
}

module "vm" {
  source              = "../../modules/vm"
  name                = "vm-acp-dev-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.subnet_app.id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  ssh_public_key      = local.ssh_public_key
  auto_shutdown_time  = var.auto_shutdown_time
  tags                = local.common_tags

  user_assigned_identity_ids = [module.managed_identity.id]
}

module "managed_identity" {
  source              = "../../modules/managed_identity"
  name                = "id-acp-dev-jpe-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  tags                = local.common_tags
}

module "keyvault" {
  source              = "../../modules/keyvault"
  name                = "kv-acp-dev-jpe-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  tags                = local.common_tags

  allowed_ip_addresses = [trimsuffix(var.allowed_ssh_source_ip, "/32")]
  allowed_subnet_ids   = [module.subnet_app.id]
}

module "subnet_pe" {
  source               = "../../modules/subnet"
  name                 = "snet-acp-dev-pe-001"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.1.2.0/24"]
}

module "pep_blob" {
  source              = "../../modules/private_endpoint"
  name                = "pep-acp-dev-blob-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.subnet_pe.id
  target_resource_id  = module.storage.id
  subresource_name    = "blob"
  private_dns_zone_id = data.azurerm_private_dns_zone.this["blob"].id
  tags                = local.common_tags

  # DNS のリンクが先にできていないと、名前解決が切り替わらない
  depends_on = [azurerm_private_dns_zone_virtual_network_link.dev]
}

module "pep_kv" {
  source              = "../../modules/private_endpoint"
  name                = "pep-acp-dev-kv-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  subnet_id           = module.subnet_pe.id
  target_resource_id  = module.keyvault.id
  subresource_name    = "vault"
  private_dns_zone_id = data.azurerm_private_dns_zone.this["vault"].id
  tags                = local.common_tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dev]
}
