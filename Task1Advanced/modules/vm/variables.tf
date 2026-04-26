variable "name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "zone" {
  description = "Availability zone (e.g. ru-central1-a)"
  type        = string
  default     = "ru-central1-a"
}

variable "platform_id" {
  description = "Hardware platform for the VM (standard-v1, standard-v2, standard-v3)"
  type        = string
  default     = "standard-v3"
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
  description = "Guaranteed vCPU share in percent (5, 20, 50, 100)"
  type        = number
  default     = 100
}

variable "boot_disk_image_id" {
  description = "Image ID for the boot disk"
  type        = string
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20
}

variable "disk_size" {
  description = "Additional (data) disk size in GB"
  type        = number
}

variable "disk_type" {
  description = "Additional disk type: network-hdd or network-ssd"
  type        = string
  default     = "network-hdd"

  validation {
    condition     = contains(["network-hdd", "network-ssd", "network-ssd-nonreplicated"], var.disk_type)
    error_message = "disk_type must be one of: network-hdd, network-ssd, network-ssd-nonreplicated."
  }
}

variable "subnet_id" {
  description = "Subnet ID to attach the VM network interface to"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key content for VM access"
  type        = string
  sensitive   = true
}

variable "vm_user" {
  description = "Linux user for SSH access"
  type        = string
  default     = "ubuntu"
}

variable "nat" {
  description = "Whether to assign a public (NAT) IP address to the VM"
  type        = bool
  default     = false
}

variable "labels" {
  description = "Map of labels to apply to all resources"
  type        = map(string)
  default     = {}
}
