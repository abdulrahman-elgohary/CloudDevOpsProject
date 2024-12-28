#VPC Variables
variable "vpc_cidr" {
    type = string
}

variable "vpc_name" {
    type = string
}

variable igw_name {
    type = string
}   

#Subnet Variables

variable "public_subnet_cidr" {
    type = string
}

variable "public_subnet_name" {
    type = string
}

variable "availability_zone" {
    type = string
}

variable "public_route_table_name" {
    type = string
}

#Security Group Variable 

variable "ec2-sg-name" {
    type = string
}

# Ec2 variables
variable "instance_type" {
    type = list(string)
}

variable "ec2_key" {
    type = string
}

variable "ec2_name" {
     type = list(string)
}
