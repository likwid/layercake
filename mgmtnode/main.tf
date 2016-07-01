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

module "ami" {
  source        = "github.com/terraform-community-modules/tf_aws_ubuntu_ami/ebs"
  region        = "${var.region}"
  distribution  = "trusty"
  instance_type = "${var.instance_type}"
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
  ami                    = "${module.ami.ami_id}"
  source_dest_check      = false
  iam_instance_profile   = "${var.instance_iam_profile.name}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.mgmt_node.id}"]
  monitoring             = false
  tags {
    Name        = "management"
    Environment = "${var.environment}"
  }
}

