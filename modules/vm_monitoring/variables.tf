variable "name" {
  description = "Data Collection Rule 名（例: dcr-acp-dev-linux-001）"
  type        = string
}

variable "location" {
  description = "リージョン（ワークスペースと同じリージョンにする）"
  type        = string
}

variable "resource_group_name" {
  description = "DCR を作成する Resource Group 名"
  type        = string
}

variable "vm_id" {
  description = "監視対象の VM の ID"
  type        = string
}

variable "user_assigned_identity_id" {
  description = "Agent の認証に使う User-assigned Managed Identity の ID（VM に割り当て済みのもの）"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "送り先の Log Analytics ワークスペースの ID"
  type        = string
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}
