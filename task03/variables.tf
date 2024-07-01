variable "resource_group_name" {
  type        = string
}
variable "location" {
  type        = string
}
variable "storage_account_name" {
  type        = string
}
variable "vnet_name" {
  type        = string
}
variable "account_tier" {
  type        = string
}
variable "account_replication_type" {
  type        = string
}
variable "public_subnet_name" {
  type        = string
}
variable "private_subnet_name" {
  type        = string
}
variable "tag_name" {
  type        = string
}
variable "vnet_address" {
  type        = list
}
variable "subnet1_address" {
  type        = list
}
variable "subnet2_address" {
  type        = list
}