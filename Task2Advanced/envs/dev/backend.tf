terraform {
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    bucket   = "tf-state-future20"
    key      = "env/dev/terraform.tfstate"
    region   = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}
