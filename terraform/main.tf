provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = var.instance_type
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-portfolio-bucket-12345"
  acl    = "private"
}
