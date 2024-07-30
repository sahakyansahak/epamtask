output "sql_server_name" {
  value = azurerm_mssql_server.sqlserver-epam-dev.name
}

output "sql_database_name" {
  value = azurerm_mssql_database.sqldb-epam-dev.name
}