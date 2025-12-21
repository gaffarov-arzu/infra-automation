provider "aws" {
  region = "us-east-1"
}

module "network" {
  source = "../../modules/network"
  vpc_cidr = "10.1.0.0/16"
  public_subnet_cidr = "10.1.1.0/24"
  az = "us-east-1a"
  env = "prod"
}

module "security" {
  source = "../../modules/security"
  vpc_id = module.network.vpc_id
  env = "prod"
}

module "compute" {

