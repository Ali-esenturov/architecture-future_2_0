# Module: vm

Creates a Yandex Cloud virtual machine with an attached data disk. All parameters are passed via variables — the module contains no hardcoded environment-specific values.

## Resources

| Resource | Description |
|---|---|
| `yandex_compute_instance` | Virtual machine |
| `yandex_compute_disk` | Attached data disk (secondary disk) |

## Input variables

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `name` | `string` | yes | — | VM name (also used as prefix for the data disk) |
| `zone` | `string` | no | `ru-central1-a` | Availability zone |
| `platform_id` | `string` | no | `standard-v3` | Hardware platform (`standard-v1`, `standard-v2`, `standard-v3`) |
| `cores` | `number` | yes | — | Number of vCPU cores |
| `memory` | `number` | yes | — | RAM size in GB |
| `core_fraction` | `number` | no | `100` | Guaranteed vCPU share in percent (5, 20, 50, 100) |
| `boot_disk_image_id` | `string` | yes | — | Image ID for the boot disk |
| `boot_disk_size` | `number` | no | `20` | Boot disk size in GB |
| `disk_size` | `number` | yes | — | Data disk size in GB |
| `disk_type` | `string` | no | `network-hdd` | Data disk type: `network-hdd`, `network-ssd`, `network-ssd-nonreplicated` |
| `subnet_id` | `string` | yes | — | Subnet ID for the network interface |
| `ssh_public_key` | `string` | yes | — | SSH public key content (sensitive) |
| `vm_user` | `string` | no | `ubuntu` | Linux user for SSH access |
| `nat` | `bool` | no | `false` | Assign a public (NAT) IP address |
| `labels` | `map(string)` | no | `{}` | Labels to apply to all resources |

## Outputs

| Name | Description |
|---|---|
| `vm_id` | ID of the virtual machine |
| `vm_name` | Name of the virtual machine |
| `internal_ip` | Internal IP address |
| `external_ip` | External (NAT) IP address; empty string if NAT is disabled |
| `disk_id` | ID of the attached data disk |
| `disk_name` | Name of the attached data disk |

## Usage

The module is called from each environment's `main.tf`. Variables are supplied via a `.tfvars` file.

### Dev

```bash
cd envs/dev
terraform init
terraform apply -var-file=dev.tfvars
```

### Stage

```bash
cd envs/stage
terraform init
terraform apply -var-file=stage.tfvars
```

### Prod

```bash
cd envs/prod
terraform init
terraform apply -var-file=prod.tfvars
```

## Environment comparison

| Parameter | dev | stage | prod |
|---|---|---|---|
| Cores | 2 | 2 | 4 |
| RAM, GB | 4 | 8 | 16 |
| CPU fraction | 20% | 50% | 100% |
| Boot disk, GB | 20 | 30 | 50 |
| Data disk, GB | 20 | 50 | 100 |
| Disk type | network-hdd | network-ssd | network-ssd |
| NAT (public IP) | false | true | true |
| Zone | ru-central1-a | ru-central1-b | ru-central1-a |

## Before applying

Replace the placeholder values in the `.tfvars` file:

- `REPLACE_WITH_YOUR_FOLDER_ID` — your Yandex Cloud folder ID
- `REPLACE_WITH_YOUR_SUBNET_ID` — subnet ID in the target folder
- `REPLACE_WITH_YOUR_SSH_PUBLIC_KEY` — contents of your public SSH key (e.g. `~/.ssh/id_rsa.pub`)

To avoid passing sensitive values on the command line, export the token via environment variable:

```bash
export YC_TOKEN=$(yc iam create-token)
```
