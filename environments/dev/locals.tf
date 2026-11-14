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

locals {
  # 変数で渡されていればそれを、無ければ手元の鍵ファイルを使う。
  # 末尾の改行の有無で差分が出ないよう、前後の空白は取り除く
  ssh_public_key = trimspace(
    var.ssh_public_key != null ? var.ssh_public_key : file(pathexpand(var.ssh_public_key_path))
  )
}
