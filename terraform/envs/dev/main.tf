##############################
# PROVIDER
##############################
provider "aws" {
  region = "us-west-2"
}

##############################
# VPC (varsa kullan / yoksa oluştur)
##############################
data "aws_vpcs" "existing" {}

locals {
  existing_vpc = length(data.aws_vpcs.existing.ids) > 0 ? data.aws_vpcs.existing.ids[0] : null
}

resource "aws_vpc" "main_vpc" {
  count      = local.existing_vpc == null ? 1 : 0
  cidr_block = "10.0.0.0/16"
  tags = { Name = "dev-vpc" }
}

data "aws_vpc" "used_vpc" {
  id = local.existing_vpc != null ? local.existing_vpc : aws_vpc.main_vpc[0].id
}

##############################
# SUBNET (varsa kullan / yoksa oluştur)
##############################
data "aws_subnets" "existing_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.used_vpc.id]
  }
}

locals {
  subnet_exists = length(data.aws_subnets.existing_subnets.ids) > 0 ? true : false
}

resource "aws_subnet" "public_subnet" {
  count                   = local.subnet_exists ? 0 : 1
  vpc_id                  = data.aws_vpc.used_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"
  tags = { Name = "dev-public-subnet" }
}

data "aws_subnet" "used_subnet" {
  id = local.subnet_exists ? data.aws_subnets.existing_subnets.ids[0] : aws_subnet.public_subnet[0].id
}

##############################
# SECURITY GROUP (varsa kullan / yoksa oluştur)
##############################
data "aws_security_groups" "existing_sg" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.used_vpc.id]
  }
}

locals {
  sg_exists = length([for sg in data.aws_security_groups.existing_sg.ids : sg if sg == "dev-sg"]) > 0
}

resource "aws_security_group" "app_sg" {
  count       = local.sg_exists ? 0 : 1
  name        = "dev-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.used_vpc.id

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

data "aws_security_group" "used_sg" {
  id = local.sg_exists ? data.aws_security_groups.existing_sg.ids[0] : aws_security_group.app_sg[0].id
}

##############################
# EXISTING IAM ROLE
##############################
data "aws_iam_role" "existing_dev_role" {
  name = "dev-role"
}

##############################
# EXISTING INSTANCE PROFILE
##############################
data "aws_iam_instance_profile" "existing_profile" {
  name = "dev-role-profile"
}

##############################
# SSH KEY PAIR (varsa kullan / yoksa oluştur)
##############################
data "aws_key_pair" "existing_key" {
  key_name = "my-key"
}

resource "aws_key_pair" "my_key" {
  count      = can(data.aws_key_pair.existing_key.key_name) ? 0 : 1
  key_name   = "my-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHk/zcBgXqANXR4hQux6FaCnS1nEdcr73ZTVFPpOBLRp+XzaK9mQJBCWfhKOVS+q84tH16YGwv5hzoIlPGwK9DcYteeeKF9tRLj3OwUEiEF1kOUZS397BtG3WzGCjgVtER5/+V7FjPi3TZ+d7DHOSL8nGAIjMfp2lhjcse7lCH36uvtl/q7ZRu1TUOlWC7WK11TEu95pvwYx/6HGVNbax1ZfMR5//pg5+CfMhKLrDABTAbv/3n63gLI6V3ssU3CqI3NUJWl973LiEoVJt59InFaAiqkZzZ//4Z/go+KY59eaKjAnmyId54kyeUYrCT+6b48AILjmMW3JSQyna9OY8dC9RFzq/tBE0Rzvh2frYtLpaAg/ErxfhuCPgoT3BeE0tK9vVywc+b6nhN9fd8JCQBHmmNeXm9hHwWnn4qbsOrkI9Rhx/Z5mbB9Wf7uk7D9dbGTwQVG94pPLksd1CDUWGca7TlHoMzO5rS2cqQkRwDWzOL4ngaSNbaM+gXPMqlnO0WEd80RZUeg6ykvcDTZCXSOBZWoFjrJZikn0XJi6aCH4c5ij42MlMa0HUG52oZ6fSAigSfdTo1Y84VZxRDC9prfzc95chh5MxJWB8OjWq2QrnNR/rLDMewMLNOTVmYFfXFkx8gCFUpaj1INWcKRRIlBwKghNQXh962ckISBoaRlw== your_email@example.com"
}

locals {
  key_to_use = can(data.aws_key_pair.existing_key.key_name) ? data.aws_key_pair.existing_key.key_name : aws_key_pair.my_key[0].key_name
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
  iam_instance_profile    = data.aws_iam_instance_profile.existing_profile.name
  key_name                = local.key_to_use

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

output "iam_role_arn" {
  value = data.aws_iam_role.existing_dev_role.arn
}

output "instance_id" {
  value = aws_instance.app_instance.id
}

output "key_name" {
  value = local.key_to_use
}
