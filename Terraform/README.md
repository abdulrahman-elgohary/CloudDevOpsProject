## Terraform Structure

![image](https://github.com/user-attachments/assets/14b84c14-be0c-478f-91ba-4546bae0f55b)

## Prequesites 
### Step 1: Install Terraform 

- Update Ubuntu System
  ```bash
  sudo apt update -y
  ```
- Install required dependencies for downloading Terraform
  ```bash
  sudo apt install -y gnupg software-properties-common curl
  ```
- Add the Hashicorp GPG Key
  ```bash
  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  ```
- Add the HashiCorp Repository
  ```bash
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  ```
- Update the system again after adding the repo
  ```bash
  sudo apt update -y 
  ```
- Install Terraform 
  ```bash
  sudo apt install terraform
  ```
- Enable Tab Completion
  ```bash
  terraform -install-autocomplete
  ```
- Restart your terminal session to apply this change.
---

### Step 2: Install AWS CLI Using the Official AWS CLI v2 Package
- Download the AWS CLI v2 Package
  ```bash
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  ```
- Unzip the Downloaded File
  ```bash
  unzip awscliv2.zip
  ```
- Run the Installer
  ```bash
  sudo ./aws/install
  ```
### Step 3: Configure AWS CLI
- Go to your AWS acoount `IAM` > `User` > Press on your IAM User > Choose `Security Credentials` tab > Navigate to `Create access key`
- After Creating your access key execute the following command
  ```bash
  aws configure
  ```
- Insert the following entries
  ```bash
  AWS Access Key ID [None]: <your-access-key-id>
  AWS Secret Access Key [None]: <your-secret-access-key>
  Default region name [None]: us-east-1
  Default output format [None]: json
  ```
---

## Steps:

## Step 1: Prepare the Backend of Terraform

**1.1 Adjust the cloud provider**
- Create a directory and name it `Terraform` then navigate to it.
  ```bash
  mkdir Terraform && cd Terraform
  ```
- Create a file called `provider.tf` and write the following entry:
  ```bash
  #Specify the version of hasicorp to use for building the infrastructure
  terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    }
  }
  #Specify the region for establishing the infrastrucute
  provider "aws" {
    region = "us-east-1"
  }
  ```

**1.2 Apply the Lock user feature**
- This feature will prevent two or more users to manage terraform at the same time.

- Navigate to `S3` Service in your aws account and create S3 bucket manually and give it a unique name

  ![image](https://github.com/user-attachments/assets/84907056-65ac-492b-a604-d5fbedc382cd)

- Navigate to `DynamoDB` Service > `Tables` > `Create table`
- Give it a name then make the primary key `LockID`

  ![image](https://github.com/user-attachments/assets/816089cf-266e-4d58-8a28-ab6844265128)

- Create `backend.tf` file with the following entry:
  ```bash
  terraform {
  backend "s3" {
    bucket = "statefull-terraform-bucket-12-20-2024"
    key    = "terraform-file-state.tfstate"
    region = "us-east-1"
    dynamodb_table = "Lock_users"
    }
  }
  ```
---
## Step 2: Start creating the modules
- Create the `main.tf` root file
  ```bash
  touch main.tf
  ```
- Create 4 modules with their required files `main.tf` , `variables.tf` , `terraform.tfvars` `outputs.rf`.
  ```bash
  mkdir -p modules/{vpc,subnet,ec2,security_group}
  tocuh modules/{vpc,subnet,ec2,security_group}/{main.tf,variables.tf,terraform.tfvars,outputs.tf}
  ```
---
## Step 3: Create the `vpc` module.
- Define the following variables in `variables.tf`:
  ```bash
  variable "vpc_cidr" {
    type = string
  }

  variable "vpc_name" {
      type = string
  }
  
  variable igw_name {
      type = string
  }   
  ```
- Define the required outputs to be used in other modules in `outputs.tf` file
  ```bash
  output "vpc_id" {
    value = aws_vpc.iv_vpc.id
  }
  
  output "igw_id" {
      value = aws_internet_gateway.iv_igw.id
  }
  ```
- Define the resources inside `main.tf` file
  ```bash
  #Create a VPC
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
  ```
---
## Step 4: Create the `subnet` module.

- Define the following variables in `variables.tf`:
  ```bash
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
  ```

- Define the required outputs to be used in other modules in `outputs.tf` file
  ```bash
  output "subnet_id" {
    value = aws_subnet.public.id
  }
  ```
  
- Define the resources inside `main.tf` file
  ```bash
  #Create a public subnet
  resource "aws_subnet" "public" {
    vpc_id            = var.vpc_id
    cidr_block        = var.public_subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true
     
  tags = {
      Name = var.public_subnet_name
    }
  }
  
  #Create a route table
  resource "aws_route_table" "public_rt" {
    vpc_id = var.vpc_id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.igw_id
    }
    tags = {
      Name = var.public_route_table_name
    }
  }
  
  #Create a route table association
  resource "aws_route_table_association" "public_rt_association" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public_rt.id
  }

  ```
---
## Step 5: Create the `security_group` module.

- Define the following variables in `variables.tf`:
  ```bash  
  variable "vpc_id" {
      type = string
  }
  
  variable "ec2-sg-name" {
      type = string
  }
  ```
- Define the required outputs to be used in other modules in `outputs.tf` file
  ```bash
  output "sg_id" {
    value = aws_security_group.ec2-sg.id
  }
  ```
- Define the resources inside `main.tf` file
  ```bash
  #Create a security group for ec2
  resource "aws_security_group" "ec2-sg" {
    name        = "ec2-sg"
    description = "Allow HTTP & HTTPS inbound traffic and ssh"
    vpc_id      = var.vpc_id
    ingress {
      description = "HTTP from VPC"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
      ingress {
      description = "HTTPS from VPC"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

      ingress {
      description = "SonarQube from VPC"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  
    ingress {
      description = "Jenkins port from VPC"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
      ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = var.ec2-sg-name
    }
  }
  ```
---
## Step 6: Create the `ec2` module.

- Define the following variables in `variables.tf`:
  ```bash  
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
  ```
- Define the resources inside `main.tf` file
  ```bash
   #Create an Ec2 in a public subnet
  resource "aws_instance" "ec2_instance" {
    ami           = data.aws_ami.Amazon-linux-ami.id
    instance_type = var.instance_type
    subnet_id     = var.subnet_id
    security_groups = [var.sg_id]
    key_name = var.ec2_key
    iam_instance_profile = var.iam_ec2_instance_name
  user_data = <<-EOF
  #!/bin/bash
  sudo apt-get update -y
  sudo apt-get install -y amazon-cloudwatch-agent
  cat <<EOT > /opt/aws/amazon-cloudwatch-agent/bin/config.json
  {
    "logs": {
      "logs_collected": {
        "files": {
          "collect_list": [
            {
              "file_path": "/var/log/syslog",
              "log_group_name": "/ec2/logs",
              "log_stream_name": "{instance_id}"
            }
          ]
        }
      }
    },
    "metrics": {
      "metrics_collected": {
        "cpu": {
          "measurement": [
            "cpu_usage_idle",
            "cpu_usage_iowait",
            "cpu_usage_user",
            "cpu_usage_system"
          ],
          "resources": ["*"],
          "totalcpu": true
        },
        "disk": {
          "measurement": [
            "disk_free",
            "disk_used",
            "disk_used_percent"
          ],
          "resources": ["*"]
        },
        "mem": {
          "measurement": [
            "mem_used_percent",
            "mem_available",
            "mem_total"
          ]
        }
      }
    }
  }
  EOT
  sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json \
    -s
  EOF
  tags = {
      Name = var.ec2_name
    }
  }
  ```
---
## Step 7: Create the `iam_role` module.

- Define the resources inside `main.tf` file
```bash
 #Create Iam Role
  resource "aws_iam_role" "ec2_role" {
    name = "ec2-cloudwatch-role"
  
    assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
  }
  #Create Iam cloudwatch policy
  resource "aws_iam_policy" "cloudwatch_policy" {
    name        = "cloudwatch-metrics-policy"
    description = "Policy to allow EC2 to send metrics to CloudWatch"
    policy      = <<EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": [
                  "cloudwatch:PutMetricData",
                  "logs:CreateLogStream",
                  "logs:PutLogEvents",
                  "logs:CreateLogGroup"
              ],
              "Resource": "*"
          }
      ]
  }
  EOF
  }
  
  #Attach policy to role
  resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attach" {
    policy_arn = aws_iam_policy.cloudwatch_policy.arn
    role = aws_iam_role.ec2_role.name
  }
  
  #Create Iam Instance Profile
  resource "aws_iam_instance_profile" "ec2_profile" {
    name = "ec2-cloudwatch-profile"
    role = aws_iam_role.ec2_role.name
  }
  ```
- Define the required outputs to be used in other modules in `outputs.tf` file
  ```bash
  output "iam_instance_profile_name" {
    value = aws_iam_instance_profile.ec2_profile.name
  }
  ```
## Step 8: Apply Terraform resources

```bash
terraform init
terraform apply
```
---
## Notes
- Run the following AWS CLI command to verify the exact AMI name:
  ```bash
  aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=al2023*" \
    --region us-east-1 \
    --query "Images[*].[ImageId,Name]" \
    --output table
  ```





  
