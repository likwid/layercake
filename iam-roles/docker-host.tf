resource "aws_iam_policy" "docker_host" {
  name        = "docker-host-role-policy-${var.name}-${var.environment}"
  description = "Allows docker hosts to access resources as needed"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${var.docker_registry_arn}",
        "${var.docker_registry_arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "docker_host" {
  name = "docker-host-role-${var.name}-${var.environment}"

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

resource "aws_iam_instance_profile" "docker_host" {
  name  = "docker-host-instance-profile-${var.name}-${var.environment}"
  path  = "/"
  roles = ["${aws_iam_role.docker_host.name}"]
}

resource "aws_iam_policy_attachment" "docker_host" {
  name       = "docker-host-iam-policy-attachment-${var.name}-${var.environment}"
  roles      = ["${aws_iam_role.docker_host.name}"]
  policy_arn = "${aws_iam_policy.docker_host.arn}"
}

output "docker_host_name" {
  value = "${aws_iam_role.docker_host.name}"
}

output "docker_host_profile" {
  value = "${aws_iam_instance_profile.docker_host.id}"
}

output "docker_host_profile_name" {
  value = "${aws_iam_instance_profile.docker_host.name}"
}
