data "aws_ami" "ubuntu_22" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's AWS Account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


variable "instance_type" {
    type = string
    default = "t2.medium"
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
