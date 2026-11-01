variable "name" {
  description = "Private DNS Zone 名（Azure の規定名。例: privatelink.blob.core.windows.net）"
  type        = string
}

variable "resource_group_name" {
  description = "所属する Resource Group 名"
  type        = string
}

variable "linked_vnet_ids" {
  description = "リンクする VNet の {リンク名の識別子 = VNet ID}（例: { hub = \"...\" }）"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}
