output "app_service_plan_id" {
  value = azurerm_service_plan.asp1.id
}
output "web_app_name" {
  value = azurerm_windows_web_app.as1.name
}

output "app_service_id" {
  value = azurerm_windows_web_app.as1.id
}