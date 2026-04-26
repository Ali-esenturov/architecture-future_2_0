terraform {
  required_version = ">= 1.3.0"

  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.90"
    }
  }
}

resource "yandex_compute_disk" "data" {
  name   = "${var.name}-data"
  zone   = var.zone
  type   = var.disk_type
  size   = var.disk_size
  labels = var.labels
}

resource "yandex_compute_instance" "vm" {
  name        = var.name
  zone        = var.zone
  platform_id = var.platform_id
  labels      = var.labels

  resources {
    cores         = var.cores
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.boot_disk_image_id
      size     = var.boot_disk_size
    }
  }

  secondary_disk {
    disk_id = yandex_compute_disk.data.id
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = var.nat
  }

  metadata = {
    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
  }
}
