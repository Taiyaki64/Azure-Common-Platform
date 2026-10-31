variable "name" {
  description = "Key Vault 名（3〜24文字・全世界で一意）"
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

variable "allowed_ip_addresses" {
  description = "ファイアウォールで許可する接続元 IP（/32 は付けない）"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "ファイアウォールで許可する Subnet の ID（サービスエンドポイントが必要）"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}