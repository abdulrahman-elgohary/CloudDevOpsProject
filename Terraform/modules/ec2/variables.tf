data "aws_ami" "Amazon-linux-ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-2023.6.20241111.0-kernel*"] # Pattern for Amazon Linux 2023 AMIs
  }
}


variable "instance_type" {
    type = string
}

variable "sg_id" {
    type = string
}

variable "subnet_id" {
    type = string
}

variable "ec2_name" {
     type = string
}

variable "ec2_key" {
    type = string
}

variable "iam_ec2_instance_name" {
  type = string
}