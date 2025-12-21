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
