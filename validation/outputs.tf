output "validated_addresses" {
  description = "IP-адрес и список адресов после проверки."
  value = {
    address   = var.ip_address
    addresses = var.ip_addresses
  }
}
