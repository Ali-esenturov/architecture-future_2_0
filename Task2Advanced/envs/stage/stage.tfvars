# Non-sensitive values — safe to commit
# Sensitive vars (folder_id, subnet_id, ssh_public_key) are injected
# by CI/CD via TF_VAR_* environment variables from GitHub Secrets

zone               = "ru-central1-b"
vm_name            = "future20-stage"
cores              = 2
memory             = 8
core_fraction      = 50
boot_disk_image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04 LTS
boot_disk_size     = 30
disk_size          = 50
disk_type          = "network-ssd"
vm_user            = "ubuntu"
nat                = true

labels = {
  env     = "stage"
  project = "future20"
  managed = "terraform"
}
