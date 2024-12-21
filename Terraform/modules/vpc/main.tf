#Create a Vpc
resource "aws_vpc" "iv_vpc" {

    cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
  
}

#Create an Internet Gateway
resource "aws_internet_gateway" "iv_igw" {
  vpc_id = aws_vpc.iv_vpc.id
  tags = {
    Name = var.igw_name
  }
}

