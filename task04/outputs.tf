output "public_ip_address" {
  description = "The public IP address of the VM."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "vm_id" {
  description = "The ID of the Virtual Machine."
  value       = azurerm_linux_virtual_machine.vm.id
}

output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "vnet_name" {
  description = "The name of the Virtual Network."
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  description = "The name of the Subnet."
  value       = azurerm_subnet.subnet.name
}

output "network_interface_id" {
  description = "The ID of the Network Interface."
  value       = azurerm_network_interface.nic.id
}

output "nsg_id" {
  description = "The ID of the Network Security Group."
  value       = azurerm_network_security_group.nsg.id
}
