# 全リソースに付ける共通タグ。リソース側では tags = local.common_tags と書く
locals {
  common_tags = {
    Project     = "AzureCommonPlatform"
    Environment = "hub"
    Owner       = "Taiyaki64"
    ManagedBy   = "Terraform"
  }
}

locals {
  # Private Endpoint 用の Private DNS Zone（Azure の規定名。キーは用途の識別子）
  private_dns_zones = {
    blob  = "privatelink.blob.core.windows.net"
    vault = "privatelink.vaultcore.azure.net"
  }
}

