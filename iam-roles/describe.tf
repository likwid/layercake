resource "aws_iam_policy" "describe" {
  name        = "describe-role-policy-${var.name}-${var.environment}"
  description = "Allows Describe API calls on various resources"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "rds:Describe*",
        "elasticache:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "describe" {
  name = "describe-role-${var.name}-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "describe" {
  name  = "describe-instance-profile-${var.name}-${var.environment}"
  path  = "/"
  roles = ["${aws_iam_role.describe.name}"]
}

resource "aws_iam_policy_attachment" "describe" {
  name       = "describe-iam-policy-attachment-${var.name}-${var.environment}"
  roles      = ["${aws_iam_role.describe.name}"]
  policy_arn = "${aws_iam_policy.describe.arn}"
}

output "describe_arn" {
  value = "${aws_iam_role.describe.arn}"
}

output "describe_name" {
  value = "${aws_iam_role.describe.name}"
}

output "describe_profile" {
  value = "${aws_iam_instance_profile.describe.id}"
}

output "describe_profile_name" {
  value = "${aws_iam_instance_profile.describe.name}"
}

