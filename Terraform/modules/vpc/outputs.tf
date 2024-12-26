output "vpc_id" {
    value = aws_vpc.iv_vpc.id
}

output "igw_id" {
    value = aws_internet_gateway.iv_igw.id
}