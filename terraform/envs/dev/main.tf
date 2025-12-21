provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "../../modules/network"
  vpc_cidr = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  az = "us-east-1a"
  env = "dev"
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.network.vpc_id
  env = "dev"
}

module "compute" {
  source = "../../modules/compute"
  ami = "ami-0c55b159cbfafe1f0" # örnek Amazon Linux AMI
  instance_type = "t2.micro"
  subnet_id = module.network.public_subnet_id
  key_name = "my-key" # kendi key pair’ini yaz
  env = "dev"
}

module "iam" {
  source = "../../modules/iam"
  env = "dev"
}


