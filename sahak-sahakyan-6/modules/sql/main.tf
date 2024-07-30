resource "azurerm_mssql_server" "sqlserver-epam-dev" {
  name                         = var.server_name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
  minimum_tls_version          = "1.2"


  tags = var.tags
}

resource "azurerm_mssql_database" "sqldb-epam-dev" {
  name           = var.database_name
  server_id      = azurerm_mssql_server.sqlserver-epam-dev.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  read_scale     = true
  sku_name       = var.sku_name
  zone_redundant = true
  enclave_type   = var.enclave-type
  tags           = var.tags
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.sqlserver-epam-dev.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "allow_specific_ips" {
  for_each         = var.allowed_ip_ranges
  name             = each.key
  server_id        = azurerm_mssql_server.sqlserver-epam-dev.id
  start_ip_address = each.value
  end_ip_address   = each.value
}

