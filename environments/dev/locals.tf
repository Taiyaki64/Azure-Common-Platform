# 全リソースに付ける共通タグ。リソース側では tags = local.common_tags と書く
locals {
  common_tags = {
    Project     = "AzureCommonPlatform"
    Environment = "dev"
    Owner       = "Taiyaki64"
    ManagedBy   = "Terraform"
  }
}
