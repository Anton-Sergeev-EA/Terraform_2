resource "terraform_data" "backend_probe" {
  input = var.backend_probe_value
}

variable "backend_probe_value" {
  type        = string
  description = "Маркер для демонстрации миграции и блокировки state."
  default     = "terraform-05"
}
