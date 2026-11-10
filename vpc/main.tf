terraform {
  required_version = "~> 1.12.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.244.0"
    }
  }
}

resource "yandex_vpc_network" "this" {
  name = var.name
}

resource "yandex_vpc_subnet" "this" {
  name           = "${var.name}-${var.zone}"
  network_id     = yandex_vpc_network.this.id
  zone           = var.zone
  v4_cidr_blocks = var.v4_cidr_blocks
}

output "subnet" {
  description = "Созданная подсеть и её параметры."
  value       = yandex_vpc_subnet.this
}
