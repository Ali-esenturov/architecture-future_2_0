# Task2Advanced — Terraform with Remote State and CI/CD

Extends Task1Advanced with:
- **Remote state** stored in Yandex Object Storage (S3-compatible backend)
- **GitHub Actions pipeline** with plan-on-PR and manual-approval apply

## Architecture

```
.github/workflows/terraform.yml   ← CI/CD pipeline
Task2Advanced/
├── modules/vm/                   ← reusable VM module (no hardcoded values)
└── envs/
    ├── dev/    ← 2 cores / 4 GB / HDD / no NAT
    ├── stage/  ← 2 cores / 8 GB / SSD / NAT
    └── prod/   ← 4 cores / 16 GB / SSD / NAT
```

Each environment stores its Terraform state at a separate key inside one shared bucket:

| Environment | State key |
|---|---|
| dev | `env/dev/terraform.tfstate` |
| stage | `env/stage/terraform.tfstate` |
| prod | `env/prod/terraform.tfstate` |

## Prerequisites

### 1. Create the S3 bucket for remote state

```bash
yc storage bucket create --name tf-state-future20
```

### 2. Create a static access key for the bucket

```bash
# Create a service account for Terraform
yc iam service-account create --name terraform-sa

# Grant editor role on the folder
yc resource-manager folder add-access-binding <FOLDER_ID> \
  --role editor \
  --subject serviceAccount:$(yc iam service-account get terraform-sa --format json | jq -r .id)

# Create static key (for S3 backend)
yc iam access-key create --service-account-name terraform-sa
# Save the output: key_id → YC_S3_ACCESS_KEY, secret → YC_S3_SECRET_KEY
```

### 3. Configure GitHub Secrets

Go to **Repository → Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|---|---|
| `YC_TOKEN` | IAM token: `yc iam create-token` |
| `YC_FOLDER_ID` | Your Yandex Cloud folder ID |
| `YC_S3_ACCESS_KEY` | Static key ID from step 2 |
| `YC_S3_SECRET_KEY` | Static key secret from step 2 |
| `YC_SUBNET_ID_DEV` | Subnet ID for dev environment |
| `YC_SUBNET_ID_STAGE` | Subnet ID for stage environment |
| `YC_SUBNET_ID_PROD` | Subnet ID for prod environment |
| `SSH_PUBLIC_KEY` | Contents of `~/.ssh/id_rsa.pub` |

### 4. Configure GitHub Environments (for manual approval)

Go to **Repository → Settings → Environments** and create three environments: `dev`, `stage`, `prod`.

For `stage` and `prod`, add **Required reviewers** — this creates the approval gate before `terraform apply` runs.

## CI/CD Pipeline

File: [.github/workflows/terraform.yml](../.github/workflows/terraform.yml)

### Triggers

| Event | What happens |
|---|---|
| Pull Request → `main` | `plan` for all three environments |
| Push → `main` | `plan` + `apply` for **dev** (gated by GitHub Environment approval) |
| `workflow_dispatch` | Manual `plan`, `apply`, or `destroy` for a chosen environment |

### Promotion flow

```
push to main
    │
    ▼
plan-dev ──► apply-dev (approval gate)
                │
                ▼
plan-stage ──► apply-stage (approval gate)  ← workflow_dispatch only
                │
                ▼
plan-prod ──► apply-prod (approval gate)    ← workflow_dispatch only
```

Stage and prod are only promoted via `workflow_dispatch` — never automatically.

### Security

- All credentials live in **GitHub Secrets** only — never in `.tf` or `.tfvars` files
- Sensitive variables (`folder_id`, `subnet_id`, `ssh_public_key`) are injected via `TF_VAR_*` env vars
- `*.tfstate` files are excluded from git (state lives in S3)
- `concurrency` group prevents parallel runs on the same environment (avoids state corruption)
- Each environment has its own isolated state key in the bucket

## Running locally

```bash
export YC_TOKEN=$(yc iam create-token)
export AWS_ACCESS_KEY_ID=<your-static-key-id>
export AWS_SECRET_ACCESS_KEY=<your-static-key-secret>
export TF_VAR_folder_id=<folder-id>
export TF_VAR_subnet_id=<subnet-id>
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_rsa.pub)"

cd Task2Advanced/envs/dev
terraform init
terraform plan  -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
terraform destroy -var-file=dev.tfvars
```
