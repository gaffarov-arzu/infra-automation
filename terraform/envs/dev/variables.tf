variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}
variable "az" {
  default = "us-east-1a"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "ami" {
  default = "ami-0c94855ba95c71c99"  # Örnek Amazon Linux 2 AMI
}
variable "key_name" {
  default = "my-keypair"
}
variable "env" {
  default = "dev"
}

