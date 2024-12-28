#Create an Ec2 in a public subnet
resource "aws_instance" "ec2_instance" {
  count = 2
  ami           = data.aws_ami.ubuntu_22.id
  instance_type = var.instance_type[count.index]
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
    Name = var.ec2_name[count.index]
  }
}

