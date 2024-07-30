
resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key-vault" {
  name                       = var.vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "azurerm_key_vault_secret" "sql_admin_secret" {
  name         = var.key_secret_name
  value        = random_password.sql_admin_password.result
  key_vault_id = azurerm_key_vault.key-vault.id
}