module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    vpc_name = var.vpc_name
    igw_name = var.igw_name
}

module "public_subnet" {
    source = "./modules/subnet"
    vpc_id = module.vpc.vpc_id
    public_subnet_cidr = var.public_subnet_cidr
    public_subnet_name = var.public_subnet_name
    availability_zone = var.availability_zone
    public_route_table_name = var.public_route_table_name
    igw_id = module.vpc.igw_id
}

module "security_group" {
    source = "./modules/security_group"
    vpc_id = module.vpc.vpc_id
    ec2-sg-name = var.ec2-sg-name
}

module "ec2" {
    source = "./modules/ec2"
    subnet_id = module.public_subnet.subnet_id
    sg_id = module.security_group.sg_id
    ec2_name = var.ec2_name
    instance_type = var.instance_type
    ec2_key = var.ec2_key
    iam_ec2_instance_name = module.iam_role.iam_instance_profile_name
}

module "iam_role" {
    source = "./modules/iam_role"
}

module "ec2-k8s" {
    source = "./modules/ec2-k8s"
    subnet_id = module.public_subnet.subnet_id
    sg_id = module.security_group.sg_id
    ec2_name = var.ec2_name
    instance_type = var.instance_type
    ec2_key = var.ec2_key
}

module "ec2-slave" {
    source = "./modules/ec2-slave"
    subnet_id = module.public_subnet.subnet_id
    sg_id = module.security_group.sg_id
    ec2_name = var.ec2_name
    instance_type = var.instance_type
    ec2_key = var.ec2_key
}