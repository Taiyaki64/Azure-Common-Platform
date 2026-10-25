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
