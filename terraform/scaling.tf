# Set up auto scaling on the app service plan to allow 2 instances by default
# Azure will load balance between the two instances
resource "azurerm_monitor_autoscale_setting" "asp_cpu_auto_scale" {
  name                = "Autoscale"
  resource_group_name = azurerm_resource_group.rg_fortune.name
  location            = azurerm_resource_group.rg_fortune.location
  target_resource_id  = azurerm_service_plan.asp_fortune.id
  depends_on          = [azurerm_resource_group.rg_fortune,
                        azurerm_service_plan.asp_fortune]
  profile {
    name = "defaultProfile"
    capacity {
      default = 2
      minimum = 2
      maximum = 4
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.asp_fortune.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80

      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.asp_fortune.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 60
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}

# Set up auto scaling on the app service plan to allow 2 instances by default
# Azure will load balance between the two instances
resource "azurerm_monitor_autoscale_setting" "http_cpu_auto_scale" {
  name                = "Autoscale"
  resource_group_name = azurerm_resource_group.rg_fortune.name
  location            = azurerm_resource_group.rg_fortune.location
  target_resource_id  = azurerm_service_plan.asp_fortune.id
  depends_on          = [azurerm_resource_group.rg_fortune,
                        azurerm_service_plan.asp_fortune]
  profile {
    name = "defaultProfile"
    capacity {
      default = 2
      minimum = 2
      maximum = 4
    }

    rule {
      metric_trigger {
        metric_name        = "HttpQueueLength"
        metric_resource_id = azurerm_service_plan.asp_fortune.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 70

      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "HttpQueueLength"
        metric_resource_id = azurerm_service_plan.asp_fortune.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 40
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}