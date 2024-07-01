variable "resource-group-name" {
  type    = string
  default = "cmtrb91f6bb7-rg"
}
variable "location" {
  type    = string
  default = "East US"
}
variable "storage-account-name" {
  type    = string
  default = "cmtrb91f6bb7sa"
}
variable "vnet-name" {
  type    = string
  default = "cmtrb91f6bb7-vnet"
}
variable "account-tier" {
  type    = string
  default = "Standard"
}
variable "account-replication-type" {
  type    = string
  default = "LRS"
}
variable "public-subnet-name" {
  type    = string
  default = "public"
}
variable "private-subnet-name" {
  type    = string
  default = "private"
}
variable "tag-name" {
  type    = string
  default = "Development"
}

variable "vnet-address" {
  type    = list(any)
  default = ["10.0.0.0/16"]
}

variable "subnet1-address" {
  type    = list(any)
  default = ["10.0.1.0/24"]
}

variable "subnet2-address" {
  type    = list(any)
  default = ["10.0.2.0/24"]
}
