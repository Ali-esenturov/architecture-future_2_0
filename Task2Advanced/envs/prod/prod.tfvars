# Non-sensitive values — safe to commit
# Sensitive vars (folder_id, subnet_id, ssh_public_key) are injected
# by CI/CD via TF_VAR_* environment variables from GitHub Secrets

zone               = "ru-central1-a"
vm_name            = "future20-prod"
cores              = 4
memory             = 16
core_fraction      = 100
boot_disk_image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04 LTS
boot_disk_size     = 50
disk_size          = 100
disk_type          = "network-ssd"
vm_user            = "ubuntu"
nat                = true

labels = {
  env     = "prod"
  project = "future20"
  managed = "terraform"
}
