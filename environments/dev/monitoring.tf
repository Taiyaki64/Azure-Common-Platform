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

# VM の正常性が悪化したときに通知（Resource Health）
resource "azurerm_monitor_activity_log_alert" "vm_health" {
  name                = "alert-acp-dev-vm-health-001"
  resource_group_name = module.rg.name
  location            = "global"
  scopes              = [module.vm.id]
  description         = "VM の正常性（Resource Health）が低下・利用不可になった"
  tags                = local.common_tags

  criteria {
    category = "ResourceHealth"

    resource_health {
      current = ["Degraded", "Unavailable"] # 現在の状態：低下・利用不可
      # 【実験用】ユーザー操作（停止など）も含める。確認後、PlatformInitiated だけに戻す
      reason = ["PlatformInitiated"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id # Phase4 で作成済みの dev の Action Group
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

locals {
  # メモリ使用率のしきい値（%）。テスト時に一時的に下げる
  vm_memory_threshold_percent = 85
}

# VM のメモリ使用率が高いときに通知（ログ検索アラート）
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "vm_memory" {
  name                = "alert-acp-dev-vm-memory-001"
  resource_group_name = module.rg.name
  location            = module.rg.location
  description         = "VM のメモリ使用率（5 分平均）がしきい値を超えた"
  severity            = 3 # 0（重大）〜 4（情報）。CPU（2）より一段低く
  tags                = local.common_tags

  scopes               = [data.azurerm_log_analytics_workspace.hub.id] # クエリを実行する対象（ワークスペース）
  evaluation_frequency = "P1D"                                         # 1日ごとに実行（頻度を上げると料金が上がる）
  window_duration      = "P1D"                                         # 直近 1日のデータを対象にする

  criteria {
    # 「しきい値を超えた行だけ」を返す。行が 1 行以上あれば発火する
    query = <<-KQL
      Perf
      | where ObjectName == "Memory" and CounterName == "% Used Memory"
      | where Computer == "vm-acp-dev-001"
      | summarize UsedPercent = avg(CounterValue) by Computer, bin(TimeGenerated, 5m)
      | where UsedPercent > ${local.vm_memory_threshold_percent}
    KQL

    time_aggregation_method = "Count" # 結果の「行数」で判定する
    operator                = "GreaterThan"
    threshold               = 0 # 0 行より多い（= 1 行以上）で発火

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1 # 1 回でも条件を満たしたら発火
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }
}
