resource "azurerm_service_plan" "asp1" {
  name                = var.app-service-plan-name
  location            = var.location
  resource_group_name = var.rg-name
  sku_name            = "S1"
  os_type             = "Windows"
}

resource "azurerm_windows_web_app" "as1" {
  name                = var.web-app-name
  location            = var.location
  resource_group_name = var.rg-name
  service_plan_id     = azurerm_service_plan.asp1.id
  site_config {
    always_on = true
  }
  connection_string {
    name  = var.connection_string_name
    type  = "SQLAzure"
    value = var.connection_string_value
  }
}
