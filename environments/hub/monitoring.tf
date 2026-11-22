# 現在のサブスクリプションの情報（ID の取得に使う）
data "azurerm_subscription" "current" {}

# サブスクリプション全体のアラートの通知先（共通）
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-acp-hub-jpe-001"
  resource_group_name = module.rg.name
  short_name          = "acp-hub" # メール・SMS の表示用の短い名前（12 文字以内）
  tags                = local.common_tags

  email_receiver {
    name          = "owner"
    email_address = var.alert_email

    # 共通アラートスキーマ：メトリック・ログ・Activity Log の通知を、同じ形式の JSON にそろえる。
    # のちに Webhook などで外部へ連携するときに、受け取る側の処理が 1 種類で済む
    use_common_alert_schema = true
  }
}

locals {
  # ワークスペースへ送る Activity Log のカテゴリ。取りすぎると課金が増えるので、必要なものに絞る
  activity_log_categories = [
    "Administrative", # 作成・変更・削除などの操作
    "Security",       # Defender for Cloud のアラート
    "ServiceHealth",  # Azure の障害・メンテナンス
    "ResourceHealth", # リソースの状態
    "Alert",          # 発火したアラートの記録
  ]
}

# サブスクリプションの Activity Log をワークスペースへ送る
resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  name                       = "diag-acp-sub-activity-001"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = module.log_analytics.id

  dynamic "enabled_log" {
    for_each = toset(local.activity_log_categories)
    content {
      category = enabled_log.value
    }
  }
}

# ロール割り当ての作成を通知（権限の変更に気づく）
resource "azurerm_monitor_activity_log_alert" "role_assignment" {
  name                = "alert-acp-sub-role-assignment-001"
  resource_group_name = module.rg.name
  location            = "global"                               # Activity Log アラートは特定のリージョンに属さないため、固定で global を指定する
  scopes              = [data.azurerm_subscription.current.id] # サブスクリプション全体を監視
  description         = "ロール割り当てが作成された"
  tags                = local.common_tags

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/roleAssignments/write"
    status         = "Succeeded" # 開始（Started）ではなく、成功したときだけ通知する
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# NSG のセキュリティ規則の作成・変更を通知（ネットワーク方針の逸脱に気づく）
resource "azurerm_monitor_activity_log_alert" "nsg_rule" {
  name                = "alert-acp-sub-nsg-rule-001"
  resource_group_name = module.rg.name
  location            = "global"
  scopes              = [data.azurerm_subscription.current.id]
  description         = "NSG のセキュリティ規則が作成または変更された"
  tags                = local.common_tags

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/securityRules/write"
    status         = "Succeeded"
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

# Azure 側の障害・計画メンテナンスを通知（自分の設定のせいではない問題を早く知る）
resource "azurerm_monitor_activity_log_alert" "service_health" {
  name                = "alert-acp-sub-service-health-001"
  resource_group_name = module.rg.name
  location            = "global"
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Japan East の Azure 障害・メンテナンス"
  tags                = local.common_tags

  criteria {
    category = "ServiceHealth"

    service_health {
      events    = ["Incident", "Maintenance"] # 障害と計画メンテナンス
      locations = ["Japan East", "Global"]
      # services を省略すると、すべての Azure サービスが対象になる
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}

