#Create an Ec2 in a public subnet
resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu_22.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  security_groups = [var.sg_id]
  key_name = var.ec2_key
  tags = {
    Name = var.ec2_name
  }
}

