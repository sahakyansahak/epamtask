provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resource-group-name
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name                     = var.storage-account-name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = var.account-tier
  account_replication_type = var.account-replication-type
}

resource "azurerm_virtual_network" "main" {
  name                = var.vnet-name
  address_space       = var.vnet-address
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "public" {
  name                 = var.public-subnet-name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet1-address
}

resource "azurerm_subnet" "private" {
  name                 = var.private-subnet-name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet2-address
}
