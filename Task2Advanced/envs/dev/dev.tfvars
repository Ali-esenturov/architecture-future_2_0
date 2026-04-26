# Non-sensitive values — safe to commit
# Sensitive vars (folder_id, subnet_id, ssh_public_key) are injected
# by CI/CD via TF_VAR_* environment variables from GitHub Secrets

zone               = "ru-central1-a"
vm_name            = "future20-dev"
cores              = 2
memory             = 4
core_fraction      = 20
boot_disk_image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04 LTS
boot_disk_size     = 20
disk_size          = 20
disk_type          = "network-hdd"
vm_user            = "ubuntu"
nat                = false

labels = {
  env     = "dev"
  project = "future20"
  managed = "terraform"
}
