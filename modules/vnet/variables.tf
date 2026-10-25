variable "name" {
  description = "Virtual Network 名"
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

variable "address_space" {
  description = "VNet のアドレス空間（例: [\"10.1.0.0/16\"]）"
  type        = list(string)
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}
