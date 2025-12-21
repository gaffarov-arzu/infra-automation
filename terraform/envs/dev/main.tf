##############################
# PROVIDER
##############################
provider "aws" {
  region = "us-west-2"
}

##############################
# VPC & NETWORK
##############################
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "dev-vpc" }
##############################
# PROVIDER
##############################
provider "aws" {
  region = "us-west-2"
}

##############################
# VPC & NETWORK
##############################
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "dev-vpc" }
}

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
resource "aws_security_group" "app_sg" {
  name        = "dev-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################
# EXISTING IAM ROLE
##############################
data "aws_iam_role" "existing_dev_role" {
  name = "dev-role"
}

resource "aws_iam_instance_profile" "dev_role_profile" {
  name = "dev-role-profile"
  role = data.aws_iam_role.existing_dev_role.name
}

##############################
# SSH KEY PAIR
##############################
resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")  # kendi public key dosyan
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
  vpc_security_group_ids  = [aws_security_group.app_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.dev_role_profile.name
  key_name                = aws_key_pair.my_key.key_name

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
  value = aws_security_group.app_sg.id
}

output "iam_role_arn" {
  value = data.aws_iam_role.existing_dev_role.arn
}

output "instance_id" {
  value = aws_instance.app_instance.id
}

output "key_name" {
  value = aws_key_pair.my_key.key_name
}


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
resource "aws_security_group" "app_sg" {
  name        = "dev-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############################
# EXISTING IAM ROLE
##############################
data "aws_iam_role" "existing_dev_role" {
  name = "dev-role"  # AWS'de zaten var olan rol
}

# Eğer rolün instance profile yoksa Terraform ile yaratıyoruz
resource "aws_iam_instance_profile" "dev_role_profile" {
  name = "dev-role-profile"
  role = data.aws_iam_role.existing_dev_role.name
}

##############################
# EC2 INSTANCE
##############################
# Güncel Amazon Linux 2 AMI
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
  vpc_security_group_ids  = [aws_security_group.app_sg.id]
  iam_instance_profile    = aws_iam_instance_profile.dev_role_profile.name
  key_name                = "my-key"  # kendi keypair

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
  value = aws_security_group.app_sg.id
}

output "iam_role_arn" {
  value = data.aws_iam_role.existing_dev_role.arn
}

output "instance_id" {
  value = aws_instance.app_instance.id
}
