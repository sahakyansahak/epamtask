variable "resource_group_name" {
  type    = string
  default = "cmtrb91f6bb7-rg"
}
variable "location" {
  type    = string
  default = "East US"
}
variable "storage_account_name" {
  type    = string
  default = "cmtrb91f6bb7sa"
}
variable "vnet_name" {
  type    = string
  default = "cmtrb91f6bb7-vnet"
}
variable "account_tier" {
  type    = string
  default = "Standard"
}
variable "account_replication_type" {
  type    = string
  default = "LRS"
}
variable "public_subnet_name" {
  type    = string
  default = "public"
}
variable "private_subnet_name" {
  type    = string
  default = "private"
}
variable "tag_name" {
  type    = string
  default = "Development"
}

variable "vnet_address" {
  type    = list(any)
  default = ["10.0.0.0/16"]
}

variable "subnet1_address" {
  type    = list(any)
  default = ["10.0.1.0/24"]
}

variable "subnet2_address" {
  type    = list(any)
  default = ["10.0.2.0/24"]
}
