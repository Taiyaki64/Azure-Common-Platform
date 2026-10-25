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

provider "azurerm" {
  features {}
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
  ssh_public_key      = file(pathexpand(var.ssh_public_key_path))
  auto_shutdown_time  = var.auto_shutdown_time
  tags                = local.common_tags
}
