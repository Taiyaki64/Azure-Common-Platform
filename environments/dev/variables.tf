variable "subscription_id" {
  description = "Azure サブスクリプション ID"
  type        = string
}

variable "location" {
  description = "リソースを作成するリージョン"
  type        = string
  default     = "japaneast"
}

variable "allowed_ssh_source_ip" {
  description = "SSH を許可する接続元 IP（例: 203.0.113.10/32）"
  type        = string
}

variable "admin_username" {
  description = "VM の管理者ユーザー名"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "VM に登録する SSH 公開鍵のパス"
  type        = string
  default     = "~/.ssh/acp_dev_rsa.pub"
}

variable "vm_size" {
  description = "VM のサイズ"
  type        = string
  default     = "Standard_B1s"
}

variable "auto_shutdown_time" {
  description = "自動シャットダウン時刻（HHmm 形式・日本時間）"
  type        = string
  default     = "2300"
}
