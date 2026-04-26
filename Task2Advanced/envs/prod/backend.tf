terraform {
  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    bucket   = "tf-state-future20"
    key      = "env/prod/terraform.tfstate"
    region   = "ru-central1"

    skip_credentials_validation = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
