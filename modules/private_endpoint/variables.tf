variable "name" {
  description = "Private Endpoint 名（例: pep-acp-dev-blob-001）"
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
  description = "Private Endpoint を置く Subnet の ID"
  type        = string
}

variable "target_resource_id" {
  description = "接続先リソース（Storage Account / Key Vault など）の ID"
  type        = string
}

variable "subresource_name" {
  description = "接続先のサブリソース名（Storage の Blob は blob、Key Vault は vault）"
  type        = string
}

variable "private_dns_zone_id" {
  description = "A レコードを登録する Private DNS Zone の ID"
  type        = string
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}
