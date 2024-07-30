resource "azurerm_resource_group" "rg-epam-dev" {
  name     = local.rg-name
  location = var.location
}

module "key-vault" {
  source              = "./modules/KeyVault"
  depends_on          = [azurerm_resource_group.rg-epam-dev]
  vault_name          = local.vault-name
  resource_group_name = local.rg-name
  location            = var.location
  sku_name            = var.sku-name
  key_secret_name     = var.key-secret-name
}

module "sqldb-epam-dev" {
  source                       = "./modules/sql"
  depends_on                   = [azurerm_resource_group.rg-epam-dev]
  server_name                  = local.sql-server-name
  resource_group_name          = local.rg-name
  location                     = var.location
  administrator_login          = var.administrator_login
  administrator_login_password = module.key-vault.sql_admin_password
  database_name                = local.db_name
  tags                         = var.sql-tags
  allowed_ip_ranges            = var.allowed_ip_ranges
  sku_name                     = var.sku-name-sql
  enclave-type                 = var.enclave-type

}

data "azurerm_key_vault" "keyvault" {
  depends_on = [ azurerm_resource_group.rg-epam-dev, module.key-vault ]
  name                = local.vault-name
  resource_group_name = local.rg-name
}

data "azurerm_key_vault_secret" "sql_connection_string" {
  name         = var.key-secret-name
  key_vault_id = data.azurerm_key_vault.keyvault.id
}

module "web-app" {
  source                  = "./modules/webapp"
  depends_on              = [azurerm_resource_group.rg-epam-dev, module.sqldb-epam-dev]
  app-service-plan-name   = local.app-service-plan-name
  web-app-name            = local.web-app-name
  rg-name                 = local.rg-name
  location                = var.location
  connection_string_name  = var.sql-connection-string
  connection_string_value = data.azurerm_key_vault_secret.sql_connection_string.value

}