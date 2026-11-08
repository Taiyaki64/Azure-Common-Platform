# Hub に作成済みのワークスペースを読み取る
data "azurerm_log_analytics_workspace" "hub" {
  name                = var.hub_log_analytics_name
  resource_group_name = var.hub_resource_group_name
}

# VM に Agent を入れ、DCR を適用する
module "vm_monitoring" {
  source              = "../../modules/vm_monitoring"
  name                = "dcr-acp-dev-linux-001"
  location            = module.rg.location
  resource_group_name = module.rg.name
  tags                = local.common_tags

  vm_id                      = module.vm.id
  user_assigned_identity_id  = module.managed_identity.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hub.id
}

# Key Vault の監査ログをワークスペースへ送る
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-acp-dev-kv-001"
  target_resource_id         = module.keyvault.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.hub.id

  enabled_log {
    category = "AuditEvent" # シークレットの取得・作成などの操作記録
  }
}

# 通知先
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-acp-dev-jpe-001"
  resource_group_name = module.rg.name
  short_name          = "acp-dev" # SMS・メールの表示用の短い名前（12 文字以内）
  tags                = local.common_tags

  email_receiver {
    name          = "owner"
    email_address = var.alert_email
  }
}

# VM の CPU 使用率が高いときに通知
resource "azurerm_monitor_metric_alert" "vm_cpu" {
  name                = "alert-acp-dev-vm-cpu-001"
  resource_group_name = module.rg.name
  scopes              = [module.vm.id]
  description         = "VM の CPU 使用率（5 分平均）が 80% を超えた"
  severity            = 2      # 0（重大）〜 4（情報）
  frequency           = "PT5M" # 5 分ごとに評価（頻度を上げると料金が上がる）
  window_size         = "PT5M" # 直近 5 分の平均で判定
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}
