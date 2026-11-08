variable "name" {
  description = "Log Analytics ワークスペース名"
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

variable "retention_in_days" {
  description = "ログの保持日数（30 日までは無料）"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "1 日の取り込み上限（GB）。超えるとその日の残りのログは取り込まれない"
  type        = number
  default     = 0.5
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}
