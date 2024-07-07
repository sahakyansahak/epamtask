variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "cmtr-b91f6bb7-rg"
}

variable "location" {
  description = "The location of the resource group"
  type        = string
  default     = "eastus"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "cmtr-b91f6bb7-vnet"
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "public-subnet"
}

variable "nsg_name" {
  description = "The name of the network security group"
  type        = string
  default     = "cmtr-b91f6bb7-nsg"
}

variable "nsg_rule_ssh" {
  description = "The name of the NSG rule for SSH"
  type        = string
  default     = "cmtr-22"
}

variable "public_ip_name" {
  description = "The name of the public IP"
  type        = string
  default     = "cmtr-b91f6bb7-publicip"
}

variable "netint_name" {
  description = "The name of the network interface"
  type        = string
  default     = "cmtr-b91f6bb7-nic"
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
  default     = "cmtr-b91f6bb7-vm"
}

variable "domain_name_label" {
  type    = string
  default = "cmtr-b91f6bb7-nginx"

}

variable "admin_username" {
  type    = string
  default = "epamapp"
}

variable "admin_password" {
  type      = string
  default   = "Epamapptask04."
  sensitive = true
}

variable "connection-type" {
  type    = string
  default = "ssh"
}

variable "image-info" {
  type    = list(string)
  default = ["Canonical", "UbuntuServer", "18.04-LTS", "latest"]
}

variable "disk-info" {
  type    = list(string)
  default = ["ReadWrite", "Standard_LRS"]
}

variable "vm-size" {
  type    = string
  default = "Standard_F2s_v2"
}

variable "pip-all" {
  type    = string
  default = "Static"
}

variable "private-all" {
  type    = string
  default = "Dynamic"
}

variable "private-name" {
  type    = string
  default = "internal"
}

variable "vnet-add" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet-add" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}
