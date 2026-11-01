# 全リソースに付ける共通タグ。リソース側では tags = local.common_tags と書く
locals {
  common_tags = {
    Project     = "AzureCommonPlatform"
    Environment = "dev"
    Owner       = "Taiyaki64"
    ManagedBy   = "Terraform"
  }
}

locals {
  # Hub に作成済みの Private DNS Zone（Step27-2 の locals と同じ名前）
  private_dns_zones = {
    blob  = "privatelink.blob.core.windows.net"
    vault = "privatelink.vaultcore.azure.net"
  }
}

