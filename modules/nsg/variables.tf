variable "name" {
  description = "NSG 名"
  type        = string
}

variable "location" {
  description = "リージョン"
  type        = string
}

variable "resource_group_name" {
  description = "所属する Resource Group 名"
  type        = string
}

variable "subnet_id" {
  description = "関連付ける Subnet の ID"
  type        = string
}

variable "security_rules" {
  description = "セキュリティ規則のリスト"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = optional(string, "*")
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = optional(string, "*")
  }))
  default = []
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}
