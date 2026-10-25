# モジュール化に伴うコードの場所の変更を Terraform に伝える。
# これがないと「旧リソースを削除して新規作成」と判断され、作り直しが発生する。
moved {
  from = azurerm_resource_group.main
  to   = module.rg.azurerm_resource_group.this
}

moved {
  from = azurerm_virtual_network.main
  to   = module.vnet.azurerm_virtual_network.this
}

moved {
  from = azurerm_subnet.app
  to   = module.subnet_app.azurerm_subnet.this
}

moved {
  from = azurerm_network_security_group.app
  to   = module.nsg_app.azurerm_network_security_group.this
}

moved {
  from = azurerm_network_security_rule.allow_ssh
  to   = module.nsg_app.azurerm_network_security_rule.this["Allow-SSH-From-MyIP"]
}

moved {
  from = azurerm_subnet_network_security_group_association.app
  to   = module.nsg_app.azurerm_subnet_network_security_group_association.this
}

moved {
  from = azurerm_public_ip.vm
  to   = module.vm.azurerm_public_ip.this[0]
}

moved {
  from = azurerm_network_interface.vm
  to   = module.vm.azurerm_network_interface.this
}

moved {
  from = azurerm_linux_virtual_machine.main
  to   = module.vm.azurerm_linux_virtual_machine.this
}

moved {
  from = azurerm_dev_test_global_vm_shutdown_schedule.main
  to   = module.vm.azurerm_dev_test_global_vm_shutdown_schedule.this
}
