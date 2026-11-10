terraform {
  required_version = "~> 1.12.0"
}

variable "ip_address" {
  type        = string
  description = "ip-адрес"
  nullable    = false
  default     = "192.168.0.1"

  validation {
    condition     = can(cidrhost("${var.ip_address}/32", 0))
    error_message = "Значение должно быть корректным IP-адресом."
  }
}

variable "ip_addresses" {
  type        = list(string)
  description = "список ip-адресов"
  nullable    = false
  default     = ["192.168.0.1", "1.1.1.1", "127.0.0.1"]

  validation {
    condition     = alltrue([for ip in var.ip_addresses : can(cidrhost("${ip}/32", 0))])
    error_message = "Каждый элемент списка должен быть корректным IP-адресом."
  }
}
