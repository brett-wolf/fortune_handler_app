terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.0.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Set up the resource group for the fortune app
resource "azurerm_resource_group" "rg_fortune" {
  name     = "rg-${var.prefix}"
  location = var.location
}

# Set up the storage account to be used by the app service plan
resource "azurerm_storage_account" "storage_account" {
  name                     = "fortunestorageaccount"
  resource_group_name      = azurerm_resource_group.rg_fortune.name
  location                 = azurerm_resource_group.rg_fortune.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on               = [azurerm_resource_group.rg_fortune]
  account_kind             = "StorageV2"
}

# Set up a storage blob container to store error messages
resource "azurerm_storage_container" "storage_container" {
  name                  = "errorcontainer"
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "blob"  
}

# Create a storage
resource "azurerm_storage_blob" "storage_blob" {
  name                   = "errorlog"
  storage_account_name   = azurerm_storage_account.storage_account.name
  storage_container_name = azurerm_storage_container.storage_container.name
  type                   = "Block"
}

# Set up the application insights for function app
resource "azurerm_application_insights" "ai_fortune" {
  name                = "ai-${var.prefix}"
  location            = azurerm_resource_group.rg_fortune.location
  resource_group_name = azurerm_resource_group.rg_fortune.name
  application_type    = "web"
  depends_on          = [azurerm_resource_group.rg_fortune]

  tags = {
    "hidden-link:${azurerm_resource_group.rg_fortune.id}/providers/Microsoft.Web/sites/${var.prefix}func" = "Resource"
  }

}

# Set up the app service plan for the function app
resource "azurerm_service_plan" "asp_fortune" {
  name                = "asp-${var.prefix}"
  resource_group_name = azurerm_resource_group.rg_fortune.name
  location            = azurerm_resource_group.rg_fortune.location
  os_type             = "Linux"
  sku_name            = "S1"
  depends_on          = [azurerm_resource_group.rg_fortune]
}

