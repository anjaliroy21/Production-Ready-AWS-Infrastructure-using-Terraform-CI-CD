module "vpc" {
  source = "./modules/vpc"
}

# 🔹 ALB first (so target group is ready)
module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
}

# 🔹 EC2 in PRIVATE subnet
module "ec2" {
  source = "./modules/ec2"

  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  target_group_arn  = module.alb.target_group_arn
  alb_sg_id         = module.alb.alb_sg_id
}

# 🔹 Bastion in PUBLIC subnet
module "bastion" {
  source          = "./modules/bastion"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
}