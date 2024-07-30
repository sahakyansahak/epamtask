variable "server_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "administrator_login" {
  type = string
}

variable "administrator_login_password" {
  type = string
}

variable "database_name" {
  type = string
}

variable "sku_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
variable "allowed_ip_ranges" {
  type = map(string)
}
variable "enclave-type" {
  type = string
}