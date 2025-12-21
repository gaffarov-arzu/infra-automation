#!/bin/bash

# Repo köküne git
cd ~/infra-automation || exit

# Modüller klasörleri
mkdir -p modules/network modules/compute modules/security modules/iam

# Env klasörleri
mkdir -p envs/dev

# =======================
# modules/network
cat > modules/network/main.tf <<EOF
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = { Name = "\${var.env}-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.az
  tags = { Name = "\${var.env}-subnet" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "\${var.env}-igw" }
}
EOF

cat > modules/network/variables.tf <<EOF
variable "vpc_cidr" {}
variable "public_subnet_cidr" {}
variable "az" {}
variable "env" {}
EOF

cat > modules/network/outputs.tf <<EOF
output "vpc_id" { value = aws_vpc.main.id }
output "subnet_id" { value = aws_subnet.public.id }
EOF

# =======================
# modules/compute
cat > modules/compute/main.tf <<EOF
resource "aws_instance" "app" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  key_name      = var.key_name
  tags = { Name = "\${var.env}-app" }
}
EOF

cat > modules/compute/variables.tf <<EOF
variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "key_name" {}
variable "env" {}
EOF

cat > modules/compute/outputs.tf <<EOF
output "instance_id" { value = aws_instance.app.id }
output "public_ip" { value = aws_instance.app.public_ip }
EOF

# =======================
# modules/security
cat > modules/security/main.tf <<EOF
resource "aws_security_group" "app_sg" {
  name        = "\${var.env}-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
OBOBOB    to_port     = 22
    protocol    = "tcp"
OBOBOB    cidr_blocks = ["0.0.0.0/0"]
  }
OBOBOBOBOBOB
  ingress {
    from_port   = 80
OBOBOB    to_port     = 80
OBOBOB    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
OBOBOB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
EOF

cat > modules/security/variables.tf <<EOF
variable "vpc_id" {}
variable "env" {}
EOF

cat > modules/security/outputs.tf <<EOF
output "sg_id" { value = aws_security_group.app_sg.id }
EOF

# =======================
cat > modules/iam/main.tf <<EOF
resource "aws_iam_role" "app_role" {
  name = "\${var.env}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
EOF

cat > modules/iam/variables.tf <<EOF
variable "env" {}
EOF

cat > modules/iam/outputs.tf <<EOF
output "role_arn" { value = aws_iam_role.app_role.arn }
EOF

# =======================
# envs/dev
cat > envs/dev/providers.tf <<EOF
provider "aws" {
  region = "us-east-1"
}
EOF

cat > envs/dev/backend.tf <<EOF
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "infra-automation/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
EOF

cat > envs/dev/variables.tf <<EOF
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnet_cidr" { default = "10.0.1.0/24" }
variable "az" { default = "us-east-1a" }
variable "instance_type" { default = "t3.micro" }
variable "ami" { default = "ami-0c94855ba95c71c99" }
variable "key_name" { default = "my-keypair" }
variable "env" { default = "dev" }
EOF

cat > envs/dev/main.tf <<EOF
module "network" {
  source              = "../../network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  az                  = var.az
  env                 = var.env
}

module "security" {
  source  = "../../security"
  vpc_id  = module.network.vpc_id
  env     = var.env
}

module "compute" {
  source        = "../../compute"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.network.subnet_id
  key_name      = var.key_name
  env           = var.env
}

module "iam" {
  source = "../../iam"
  env    = var.env
}
EOF

cat > envs/dev/outputs.tf <<EOF
output "vpc_id" { value = module.network.vpc_id }
output "subnet_id" { value = module.network.subnet_id }
output "instance_id" { value = module.compute.instance_id }
output "instance_public_ip" { value = module.compute.public_ip }
output "security_group_id" { value = module.security.sg_id }
output "iam_role_arn" { value = module.iam.role_arn }
EOF

echo "Tüm Terraform dosyaları başarıyla oluşturuldu!"
