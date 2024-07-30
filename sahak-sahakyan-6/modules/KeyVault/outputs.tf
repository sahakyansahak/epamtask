output "key_vault_id" {
  value = azurerm_key_vault.key-vault.id
}

output "sql_admin_password" {
  value = azurerm_key_vault_secret.sql_admin_secret.value
}

output "sql_admin_secret_id" {
  value = azurerm_key_vault_secret.sql_admin_secret.id
}
