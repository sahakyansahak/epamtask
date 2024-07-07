terraform {
  required_version = ">= 1.5.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  address_space       = var.vnet-add
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet-add
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.nsg_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "http" {
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = azurerm_resource_group.rg.name
  name = "${var.http-name}"
  priority = 1002
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "80"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_network_security_rule" "ssh" {
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name = azurerm_resource_group.rg.name
  name = "${var.nsg_rule_ssh}"
  priority = 1001
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "22"
  source_address_prefix = "*"
  destination_address_prefix = "*"
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.public_ip_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "${var.pip-all}"
  domain_name_label   = "${var.domain_name_label}"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.netint_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.private-name}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "${var.private-all}"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.vm_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm-size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
    
  os_disk {
    caching              = var.disk-info[0]
    storage_account_type = var.disk-info[1]
  }

  source_image_reference {
    publisher = var.image-info[0]
    offer     = var.image-info[1]
    sku       = var.image-info[2]
    version   = var.image-info[3]
  }

  computer_name  = var.vm_name
  disable_password_authentication = false


  connection {
    type     = var.connection-type
    user     = var.admin_username
    password = var.admin_password
    host     = azurerm_public_ip.public_ip.ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
    ]
  }

  tags = {
    environment = "testing"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
