terraform {
  required_version = "~> 1.12.0"
  backend "s3" {
    key                         = "terraform.tfstate"
    region                      = "ru-central1"
    use_lockfile                = true
    use_path_style              = true
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
  }

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.244.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}
provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = pathexpand(var.service_account_key_file)
}
