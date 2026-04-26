module "vm" {
  source = "../../modules/vm"

  name               = var.vm_name
  zone               = var.zone
  cores              = var.cores
  memory             = var.memory
  core_fraction      = var.core_fraction
  boot_disk_image_id = var.boot_disk_image_id
  boot_disk_size     = var.boot_disk_size
  disk_size          = var.disk_size
  disk_type          = var.disk_type
  subnet_id          = var.subnet_id
  ssh_public_key     = var.ssh_public_key
  vm_user            = var.vm_user
  nat                = var.nat
  labels             = var.labels
}
