variable "location" {
  type    = string
  default = "East US"
}
variable "sku-name" {
  type    = string
  default = "standard"
}
variable "sku-name-sql" {
  type    = string
  default = "P1"
}
variable "enclave-type" {
  type    = string
  default = "VBS"
}
variable "key-secret-name" {
  type    = string
  default = "sql-admin-password"
}
variable "administrator_login" {
  type    = string
  default = "sql-admin"
}
variable "sql-tags" {
  type    = map(string)
  default = {}
}
variable "allowed_ip_ranges" {
  type = map(string)
  default = {
    "ExternalIP" = "45.159.74.78" #This is my IP address
  }
}
variable "app-name" {
  type    = string
  default = "epam-app"
}
variable "sql-connection-string" {
  type = string
  default = "SQL_CONNECTION"
}

# resource group
# sql connetion web app