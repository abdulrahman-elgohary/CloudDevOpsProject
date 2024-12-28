vpc_cidr = "10.0.0.0/16"
vpc_name = "ivolve_vpc"
igw_name = "ivolve_igw"

public_subnet_cidr = "10.0.1.0/24"
public_subnet_name = "ivolve_subnet"

availability_zone = "us-east-1a"
public_route_table_name = "public_route_table"

ec2-sg-name = "public-sg"
instance_type = ["t3.xlarge","t2.small"]
ec2_name = ["ivolve_ec2","slave_ec2"]
ec2_key = "Slave"
