locals {
  app-service-plan-name = "${var.app-name}-plan"
  web-app-name          = "${var.app-name}-web1"
  sql-server-name       = "sql-server1-${var.app-name}"
  rg-name               = "rg-${var.app-name}-dev"
  db_name               = "sqldb-${var.app-name}"
  vault-name            = "${var.app-name}-key-vault1"
}
