# 何を集めて、どこへ送るか
resource "azurerm_monitor_data_collection_rule" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = "law-destination"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-Syslog"]
    destinations = ["law-destination"]
  }

  data_sources {
    # CPU・メモリ・ディスクの使用率（60 秒ごと）
    performance_counter {
      name                          = "perf-basic"
      streams                       = ["Microsoft-Perf"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "Processor(*)\\% Processor Time",
        "Memory(*)\\% Used Memory",
        "Logical Disk(*)\\% Used Space",
      ]
    }

    # 認証・システム関連の警告以上のログだけ集める（取りすぎると課金が増える）
    syslog {
      name           = "syslog-basic"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["auth", "authpriv", "daemon", "syslog"]
      log_levels     = ["Warning", "Error", "Critical", "Alert", "Emergency"]
    }
  }
}

# VM の中で動く Agent。User-assigned Managed Identity で認証する
resource "azurerm_virtual_machine_extension" "ama" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = var.vm_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = var.tags

  # User-assigned の場合は、どの Identity を使うかを明示する必要がある
  settings = jsonencode({
    authentication = {
      managedIdentity = {
        "identifier-name"  = "mi_res_id"
        "identifier-value" = var.user_assigned_identity_id
      }
    }
  })
}

# VM に DCR を適用する
resource "azurerm_monitor_data_collection_rule_association" "this" {
  name                    = "assoc-${var.name}"
  target_resource_id      = var.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.this.id

  # Agent が入ってから関連付ける（順序を明示）
  depends_on = [azurerm_virtual_machine_extension.ama]
}
