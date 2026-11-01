output "vm_public_ip" {
  description = "VM のパブリック IP"
  value       = module.vm.public_ip
}

output "vm_private_ip" {
  description = "VM のプライベート IP"
  value       = module.vm.private_ip
}

output "ssh_command" {
  description = "VM への SSH 接続コマンド"
  value       = "ssh -i ~/.ssh/acp_dev_rsa ${var.admin_username}@${module.vm.public_ip}"
}

output "storage_account_name" {
  description = "Storage Account 名"
  value       = module.storage.name
}

output "key_vault_name" {
  description = "Key Vault 名"
  value       = module.keyvault.name
}

output "key_vault_uri" {
  description = "Key Vault の URI"
  value       = module.keyvault.vault_uri
}

output "managed_identity_client_id" {
  description = "Managed Identity のクライアント ID（VM 内でのトークン取得に使う）"
  value       = module.managed_identity.client_id
}

output "private_endpoint_ips" {
  description = "Private Endpoint のプライベート IP（動作確認で名前解決の結果と比較する）"
  value = {
    blob  = module.pep_blob.private_ip_address
    vault = module.pep_kv.private_ip_address
  }
}
