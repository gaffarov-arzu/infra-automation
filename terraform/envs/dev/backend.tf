terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "infra-automation/dev/terraform.tfstate"
    region = "us-west-2"  # burayı bucket’ın gerçek bölgesi ile değiştir
  }
}
