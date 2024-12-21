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