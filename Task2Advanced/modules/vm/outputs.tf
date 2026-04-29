output "vm_id" {
  description = "ID of the virtual machine"
  value       = yandex_compute_instance.vm.id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = yandex_compute_instance.vm.name
}

output "internal_ip" {
  description = "Internal IP address of the VM"
  value       = yandex_compute_instance.vm.network_interface[0].ip_address
}

output "external_ip" {
  description = "External (NAT) IP address of the VM; empty string if NAT is disabled"
  value       = yandex_compute_instance.vm.network_interface[0].nat_ip_address
}

output "disk_id" {
  description = "ID of the attached data disk"
  value       = yandex_compute_disk.data.id
}

output "disk_name" {
  description = "Name of the attached data disk"
  value       = yandex_compute_disk.data.name
}
