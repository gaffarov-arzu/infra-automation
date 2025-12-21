output "vpc_id" { value = module.network.vpc_id }
output "subnet_id" { value = module.network.subnet_id }
output "instance_id" { value = module.compute.instance_id }
output "instance_public_ip" { value = module.compute.public_ip }
output "security_group_id" { value = module.security.sg_id }
output "iam_role_arn" { value = module.iam.role_arn }
