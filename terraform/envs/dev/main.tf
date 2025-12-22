# provider "aws" {
#   region = "us-west-2"
# }

# # VPC
# resource "aws_vpc" "main_vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = { Name = "dev-vpc" }
# }

# # Subnet
# resource "aws_subnet" "public_subnet" {
#   vpc_id     = aws_vpc.main_vpc.id
#   cidr_block = "10.0.1.0/24"
#   map_public_ip_on_launch = true
#   tags = { Name = "dev-public-subnet" }
# }

# # Security Group
# resource "aws_security_group" "dev_sg" {
#   name   = "dev-sg"
#   vpc_id = aws_vpc.main_vpc.id
#
#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # Key Pair (opsiyonel, eğer Terraform ile yaratmak istiyorsan)
# resource "aws_key_pair" "my_key" {
#   key_name   = "my-key"
#   public_key = file("~/.ssh/id_rsa.pub") # kendi public key’in
# }

# # EC2 Instance
# resource "aws_instance" "app_instance" {
#   ami                         = data.aws_ami.amazon_linux.id
#   instance_type                = "t2.micro"
#   subnet_id                    = aws_subnet.public_subnet.id
#   vpc_security_group_ids       = [aws_security_group.dev_sg.id]
#   key_name                     = aws_key_pair.my_key.key_name
#   associate_public_ip_address  = true
#
#   tags = { Name = "dev-instance" }
# }

# # Amazon Linux AMI (data)
# data "aws_ami" "amazon_linux" {
#   most_recent = true
#   owners      = ["amazon"]
#
#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }
# }

# # Outputs
# output "vpc_id" { value = aws_vpc.main_vpc.id }
# output "subnet_id" { value = aws_subnet.public_subnet.id }
# output "security_group_id" { value = aws_security_group.dev_sg.id }
# output "instance_id" { value = aws_instance.app_instance.id }
# output "public_ip" { value = aws_instance.app_instance.public_ip }
# output "key_name" { value = aws_key_pair.my_key.key_name }
