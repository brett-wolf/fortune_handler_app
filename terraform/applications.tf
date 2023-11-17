# Set up the function app
resource "azurerm_linux_function_app" "fa_fortune" {
  name                = "func-${var.prefix}"
  resource_group_name = azurerm_resource_group.rg_fortune.name
  location            = azurerm_resource_group.rg_fortune.location
  depends_on          = [azurerm_resource_group.rg_fortune,
                        azurerm_service_plan.asp_fortune,
                        azurerm_storage_account.storage_account]
  storage_account_name       = azurerm_storage_account.storage_account.name
  service_plan_id            = azurerm_service_plan.asp_fortune.id

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = 0
    #FUNCTIONS_WORKER_RUNTIME       = "python"
      #WEBSITES_MOUNT_ENABLED                = 1
      #WEBSITES_ENABLE_APP_SERVICE_STORAGE = false
      #FUNCTIONS_WORKER_RUNTIME              = "python"
      #APPINSIGHTS_INSTRUMENTATIONKEY        = "${azurerm_application_insights.ai_fortune.instrumentation_key}"
      #APPLICATIONINSIGHTS_CONNECTION_STRING = "InstrumentationKey=${azurerm_application_insights.ai_fortune.instrumentation_key};IngestionEndpoint=https://eastus-0.in.applicationinsights.azure.com/"
      #AzureWebJobsStorage = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.storage_account.name};AccountKey=${azurerm_storage_account.storage_account.primary_access_key}"
      #SCM_DO_BUILD_DURING_DEPLOYMENT = true
      #ENABLE_ORYX_BUILD = true
      #SCM_DO_BUILD_DURING_DEPLOYMENT = true
  }

  site_config {
    ftps_state        = "Disabled"
    health_check_path = "/api/healthcheck"
    always_on         = true
    use_32_bit_worker = false
    application_insights_connection_string = azurerm_application_insights.ai_fortune.connection_string
    application_insights_key               = azurerm_application_insights.ai_fortune.instrumentation_key
    application_stack {
      python_version = "3.9"
    }   
    
    app_service_logs {
      disk_quota_mb         = 25
      retention_period_days = 5      
    }
    cors {
      allowed_origins =  [
            "https://web-${var.prefix}.azurewebsites.net"
          ]
    }
  }
}

# Create the fortune function within the function app
resource "azurerm_function_app_function" "func_fortune" {
  depends_on = [ azurerm_linux_function_app.fa_fortune ]
  name = "Fortune"
  function_app_id = azurerm_linux_function_app.fa_fortune.id
  language = "Python"
  test_data = jsonencode({
    "name" = "Azure"
  })
  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })
}

# Create web app for the static web page
resource "azurerm_linux_web_app" "wa_fortune" {
  name                  = "web-${var.prefix}"
  location              = azurerm_resource_group.rg_fortune.location
  resource_group_name   = azurerm_resource_group.rg_fortune.name
  service_plan_id       = azurerm_service_plan.asp_fortune.id
  https_only            = true
  
  logs {
    http_logs {
      azure_blob_storage {
        retention_in_days = 5
        sas_url = azurerm_storage_blob.storage_blob.url
      }
    }
    application_logs {
      file_system_level = "Error"      

      azure_blob_storage {
        level = "Error"
        retention_in_days = 5
        sas_url = azurerm_storage_blob.storage_blob.url
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }
  site_config { 
    minimum_tls_version = "1.2"   
    default_documents = [ "index.html" ]
    always_on = true
    health_check_path = "/"
    
    # In azure, we need to set the application stack to PHP for static web pages
    application_stack {
      php_version = "8.0"
    }    
  }
}
