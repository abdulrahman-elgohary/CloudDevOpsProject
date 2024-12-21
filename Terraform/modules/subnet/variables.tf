variable "vpc_id" {
    type = string
}
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

variable igw_id {
    type = string
}   