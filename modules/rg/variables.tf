variable "name" {
  description = "Resource Group 名"
  type        = string
}

variable "location" {
  description = "リージョン"
  type        = string
}

variable "tags" {
  description = "リソースに付けるタグ"
  type        = map(string)
  default     = {}
}
