terraform {
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    bucket   = "tf-state-future20"
    key      = "env/prod/terraform.tfstate"
    region   = "ru-central1"

    # Required for Yandex Object Storage (not AWS)
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}
