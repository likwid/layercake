/**
 * Acts as a management node to run commands from inside AWS network
 *
 *
 * Usage:
 *
 *    module "mgmtnode" {
 *      source               = "github.com/likwid/layercake/mgmtnode"
 *      region               = "us-west-2"
 *      instance_iam_profile = ""
 *      instance_type        = "t2.micro"
 *      security_groups      = "sg-1,sg-2"
 *      vpc_id               = "vpc-12"
 *      key_name             = "ssh-key"
 *      subnet_id            = "pub-1"
 *      environment          = "prod"
 *    }
 *
 */

variable "instance_type" {
  default     = "t2.micro"
  description = "Instance type, see a list at: https://aws.amazon.com/ec2/instance-types/"
}

variable "region" {
  description = "AWS Region, e.g us-west-2"
}

variable "security_groups" {
  description = "a comma separated lists of security group IDs"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "key_name" {
  description = "The SSH key pair, key name"
}

variable "subnet_id" {
  description = "A external subnet id"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "instance_iam_profile" {
  description = "Instance IAM profile"
}

variable "launch_ami" {
  description = "AMI to launch node with"
}

variable "internal_dns_zone_id" {
  description = "DNS zone to use"
}

variable "internal_dns_name" {
  description = "DNS name, like layercake.local"
}

resource "aws_security_group" "mgmt_node" {
  name        = "management-node-sg"
  vpc_id      = "${var.vpc_id}"
  description = "Allows traffic from and to the management node"

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = -1
    security_groups = ["${split(",", var.security_groups)}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Environment = "${var.environment}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "mgmtnode" {
  ami                    = "${var.launch_ami}"
  source_dest_check      = false
  iam_instance_profile   = "${var.instance_iam_profile.name}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.mgmt_node.id}"]
  monitoring             = false
  tags {
    Name        = "management"
    Role        = "management"
    Environment = "${var.environment}"
  }
}

resource "aws_route53_record" "management" {
  zone_id = "${var.internal_dns_zone_id}"
  name    = "management.${var.internal_dns_name}"
  type    = "A"
  ttl     = 60
  records = ["${aws_instance.mgmtnode.private_ip}"]
}

output "mgmt_security_group" {
  value = "${aws_security_group.mgmt_node.id}"
}
