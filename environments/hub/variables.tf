variable "subscription_id" {
  description = "Azure サブスクリプション ID"
  type        = string
}

variable "location" {
  description = "リージョン"
  type        = string
  default     = "japaneast"
}

variable "alert_email" {
  description = "アラートの通知先メールアドレス"
  type        = string
}
