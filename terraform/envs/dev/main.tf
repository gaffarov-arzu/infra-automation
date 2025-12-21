##############################
# PROVIDER
##############################
provider "aws" {
  region = "us-west-2"
}

##############################
# EXISTING VPC
##############################
data "aws_vpcs" "existing" {}

locals {
  existing_vpc = length(data.aws_vpcs.existing.ids) > 0 ? data.aws_vpcs.existing.ids[0] : null
}

data "aws_vpc" "used_vpc" {
  id = local.existing_vpc
}

##############################
# EXISTING SUBNET
##############################
data "aws_subnets" "existing_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.used_vpc.id]
  }
}

# Sadece ilk subneti kullan
data "aws_subnet" "used_subnet" {
  id = data.aws_subnets.existing_subnets.ids[0]
}

##############################
# EXISTING SECURITY GROUP
##############################
data "aws_security_group" "used_sg" {
  filter {
    name   = "group-name"
    values = ["dev-sg"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.used_vpc.id]
  }
}

##############################
# EXISTING KEY PAIR
##############################
data "aws_key_pair" "existing_key" {
  key_name = "my-key"
}

locals {
  key_to_use = data.aws_key_pair.existing_key.key_name
}

##############################
# EC2 INSTANCE
##############################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "app_instance" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type           = "t2.micro"
  subnet_id               = data.aws_subnet.used_subnet.id
  vpc_security_group_ids  = [data.aws_security_group.used_sg.id]
  key_name                = local.key_to_use
  associate_public_ip_address = true

  tags = { Name = "dev-instance" }
}

##############################
# OUTPUTS
##############################
output "vpc_id" {
  value = data.aws_vpc.used_vpc.id
}

output "subnet_id" {
  value = data.aws_subnet.used_subnet.id
}

output "security_group_id" {
  value = data.aws_security_group.used_sg.id
}

output "instance_id" {
  value = aws_instance.app_instance.id
}

output "public_ip" {
  value = aws_instance.app_instance.public_ip
}

output "key_name" {
  value = local.key_to_use
}
