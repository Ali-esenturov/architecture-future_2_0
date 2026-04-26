variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the VM network interface"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
  sensitive   = true
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "cores" {
  description = "Number of vCPU cores"
  type        = number
}

variable "memory" {
  description = "RAM size in GB"
  type        = number
}

variable "core_fraction" {
  description = "Guaranteed vCPU share in percent"
  type        = number
}

variable "boot_disk_image_id" {
  description = "Image ID for the boot disk"
  type        = string
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
}

variable "disk_size" {
  description = "Additional data disk size in GB"
  type        = number
}

variable "disk_type" {
  description = "Additional disk type"
  type        = string
}

variable "vm_user" {
  description = "Linux user for SSH access"
  type        = string
}

variable "nat" {
  description = "Enable public IP (NAT)"
  type        = bool
}

variable "labels" {
  description = "Resource labels"
  type        = map(string)
  default     = {}
}
