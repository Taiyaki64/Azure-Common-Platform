variable "name" {
  description = "Subnet 名"
  type        = string
}

variable "resource_group_name" {
  description = "所属する Resource Group 名"
  type        = string
}

variable "virtual_network_name" {
  description = "所属する Virtual Network 名"
  type        = string
}

variable "address_prefixes" {
  description = "Subnet のアドレス範囲（例: [\"10.1.1.0/24\"]）"
  type        = list(string)
}

variable "service_endpoints" {
  description = "Subnet に設定する Service Endpoint のリスト（例: [\"Microsoft.Storage\"]）"
  type        = list(string)
  default     = []
}