variable "name" {
  description = "VM 名（vm- で始める）"
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
  description = "NIC を接続する Subnet の ID"
  type        = string
}

variable "vm_size" {
  description = "VM のサイズ"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "VM の管理者ユーザー名"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH 公開鍵の中身"
  type        = string
}

variable "os_disk_size_gb" {
  description = "OS ディスクのサイズ（GB）"
  type        = number
  default     = 30
}

variable "enable_public_ip" {
  description = "パブリック IP を作成して NIC に付けるか"
  type        = bool
  default     = true
}

variable "auto_shutdown_time" {
  description = "自動シャットダウン時刻（HHmm 形式・日本時間）"
  type        = string
  default     = "2300"
}

variable "user_assigned_identity_ids" {
  description = "VM に割り当てる User-assigned Managed Identity の ID のリスト"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}
