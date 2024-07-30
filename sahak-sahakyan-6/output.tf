output "key_vault_id" {
  value = module.key-vault.key_vault_id
}

output "sql_admin_password" {
  sensitive = true
  value     = module.key-vault.sql_admin_password
}
output "sql-admin-secret-id" {
  value = module.key-vault.sql_admin_secret_id
}
output "sql_server_name" {
  value = module.sqldb-epam-dev.sql_server_name
}

output "sql_database_name" {
  value = module.sqldb-epam-dev.sql_database_name
}
output "web-app-name" {
  value = module.web-app.web_app_name
}
output "app-service-plan-id" {
  value = module.web-app.app_service_plan_id
}
