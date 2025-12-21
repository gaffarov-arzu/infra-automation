##############################
# BACKEND (S3 ile state)
##############################
terraform {
  backend "s3" {
    bucket = "arzu-terraform-state-20251221"
    key    = "dev/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
  }
}

##############################
# PROVIDER
##############################
provider "aws" {
  region = "us-west-2"
}

##############################
# VPC
##############################
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "dev-vpc" }
}

##############################
# SUBNET
##############################
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = { Name = "dev-public-subnet" }
}

##############################
# SECURITY GROUP
##############################
resource "aws_security_group" "dev_sg" {
  name        = "dev-sg"
  description = "Dev security group"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "dev-sg" }
}

##############################
# EXISTING SSH KEY PAIR
##############################
data "aws_key_pair" "existing_key" {
  key_name = "my-key"  # AWS’de zaten var olan key adı
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
  subnet_id               = aws_subnet.public_subnet.id
  vpc_security_group_ids  = [aws_security_group.dev_sg.id]
  key_name                = data.aws_key_pair.existing_key.key_name

  tags = { Name = "dev-instance" }
}

##############################
# OUTPUTS
##############################
output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "security_group_id" {
  value = aws_security_group.dev_sg.id
}

output "instance_id" {
  value = aws_instance.app_instance.id
}

output "key_name" {
  value = data.aws_key_pair.existing_key.key_name
}
