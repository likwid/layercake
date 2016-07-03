resource "aws_iam_policy" "management_node" {
  name   = "management-node-policy-${var.name}-${var.environment}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "s3:*",
        "rds:*",
        "elasticache:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "management_node" {
  name = "management-node-role-${var.name}-${var.environment}"

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

resource "aws_iam_instance_profile" "management_node" {
  name  = "management-node-instance-profile-${var.name}-${var.environment}"
  path  = "/"
  roles = ["${aws_iam_role.management_node.name}"]
}

resource "aws_iam_policy_attachment" "management_node" {
  name       = "management-node-iam-policy-attachment-${var.name}-${var.environment}"
  roles      = ["${aws_iam_role.management_node.name}"]
  policy_arn = "${aws_iam_policy.management_node.arn}"
}

output "management_node_arn" {
  value = "${aws_iam_role.management_node.arn}"
}

output "management_node_name" {
  value = "${aws_iam_role.management_node.name}"
}

output "management_node_profile" {
  value = "${aws_iam_instance_profile.management_node.id}"
}

output "management_node_profile_name" {
  value = "${aws_iam_instance_profile.management_node.name}"
}
