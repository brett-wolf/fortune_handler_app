# Set up azure alert action group
resource "azurerm_monitor_action_group" "action_group_fortune" {
  name                = "CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.rg_fortune.name
  short_name          = "CritAlert"
  depends_on          = [azurerm_resource_group.rg_fortune]
  email_receiver {
    name                    = "sendtoadmin"
    email_address           = var.admin_email
    use_common_alert_schema = true
  }
}

# Set up an alert for CPU threshold on the app service plan
resource "azurerm_monitor_metric_alert" "metriccpualert" {
  name                 = "cpu-metric-alert"
  resource_group_name  = azurerm_resource_group.rg_fortune.name
  description          = "Action will be triggered when CPU percentage is greater than 80%"
  scopes               = [azurerm_service_plan.asp_fortune.id]
  depends_on           = [azurerm_resource_group.rg_fortune,
                          azurerm_service_plan.asp_fortune]
  target_resource_type = "Microsoft.Web/serverFarms"
  severity             = 0
  frequency            = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/serverFarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
    skip_metric_validation = true
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group_fortune.id
  }
}

# Set up an alert rule on the health check status of the function app
resource "azurerm_monitor_metric_alert" "func_metric_health_alert" {
  name                 = "func-healthcheck-metric-alert"
  resource_group_name  = azurerm_resource_group.rg_fortune.name
  description          = "Action will be triggered when the health of the function app is < 100%"
  scopes               = [azurerm_linux_function_app.fa_fortune.id]
  depends_on           = [azurerm_resource_group.rg_fortune,
                          azurerm_service_plan.asp_fortune]
  target_resource_type = "Microsoft.Web/sites"
  severity             = 0
  frequency            = "PT1M"

  criteria {
    metric_namespace = "microsoft.web/sites"
    metric_name      = "HealthCheckStatus"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group_fortune.id
  }
}

