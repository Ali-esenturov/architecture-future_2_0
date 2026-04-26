output "vm_id" {
  description = "ID of the virtual machine"
  value       = module.vm.vm_id
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = module.vm.vm_name
}

output "internal_ip" {
  description = "Internal IP address of the VM"
  value       = module.vm.internal_ip
}

output "external_ip" {
  description = "External (NAT) IP address; empty if NAT is disabled"
  value       = module.vm.external_ip
}

output "disk_id" {
  description = "ID of the attached data disk"
  value       = module.vm.disk_id
}

output "disk_name" {
  description = "Name of the attached data disk"
  value       = module.vm.disk_name
}
