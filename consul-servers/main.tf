/**
 * Provides Consul cluster for service discovery
 *
 *
 * Usage:
 *
 *    module "consul_servers" {
 *      source                 = "github.com/likwid/layercake/consul-servers"
 *      instance_type          = "t2.micro"
 *      region                 = "us-west-2"
 *      security_groups        = "sg-1,sg-2"
 *      vpc_id                 = "vpc-12"
 *      vpc_cidr               = "10.30.0.0/16"
 *      key_name               = "ssh-key"
 *      availability_zones     = "az-1,az-2"
 *      subnet_ids             = "subnet-1,subnet-2,subnet-3"
 *      instance_iam_profile   = ""
 *      environment            = "prod"
 *      mgmt_security_group    = "mgmt"
 *      cluster_security_group = "cluster"
 *      launch_ami             = "ami-123456"
 *    }
 *
 */

variable "name" {
  description = "Name of infrastructure"
}

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

variable "vpc_cidr" {
  description = "VPC cidr"
}

variable "key_name" {
  description = "The SSH key pair, key name"
}

variable "availability_zones" {
  description = "Comma separated list of AZs"
}

variable "subnet_ids" {
  description = "Comma separated list of subnet IDs"
}

variable "elb_subnet_ids" {
  description = "Comma separated list of subnets for the ELB"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "instance_iam_profile" {
  description = "Instance IAM profile"
}

variable "mgmt_security_group" {
  description = "Allows management node traffic"
}

variable "cluster_security_group" {
  description = "Allows cluster members to talk"
}

variable "launch_ami" {
  description = "AMI to launch node with"
}

variable "min_size" {
  description = "Minimum instance count"
  default     = 3
}

variable "max_size" {
  description = "Maxmimum instance count"
  default     = 9
}

variable "desired_capacity" {
  description = "Desired instance count"
  default     = 3
}

variable "internal_dns_zone_id" {
  description = "DNS zone to use"
}

variable "internal_dns_name" {
  description = "DNS name, like layercake.local"
}

resource "aws_launch_configuration" "consul" {
  name_prefix          = "consul-"
  image_id             = "${var.launch_ami}"
  instance_type        = "${var.instance_type}"
  iam_instance_profile = "${var.instance_iam_profile}"
  key_name             = "${var.key_name}"
  security_groups      = ["${var.mgmt_security_group}", "${var.cluster_security_group}"]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "consul" {
  name = "consul"
  availability_zones   = ["${split(",", var.availability_zones)}"]
  vpc_zone_identifier  = ["${split(",", var.subnet_ids)}"]
  launch_configuration = "${aws_launch_configuration.consul.id}"
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"
  termination_policies = ["OldestLaunchConfiguration", "Default"]
  load_balancers       = ["${aws_elb.private.name}"]

  tag {
    key                 = "Name"
    value               = "consul-server"
    propagate_at_launch = true
  }
  tag {
    key                 = "Role"
    value               = "consul-server"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_elb" "private" {
  name = "${var.name}-${var.environment}-private-elb"
  subnets = ["${split(",", var.elb_subnet_ids)}"]
  cross_zone_load_balancing = true
  internal = true
  security_groups = ["${var.cluster_security_group}"]

  listener { 
    instance_port = 8500
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    target = "HTTP:8500/ui/"
    healthy_threshold = 3
    unhealthy_threshold = 3
    interval = 30
    timeout = 3
  }
}

resource "aws_route53_record" "consul" {
  zone_id = "${var.internal_dns_zone_id}"
  name    = "consul.${var.internal_dns_name}"
  type    = "CNAME"
  ttl     = 60
  records = ["${aws_elb.private.dns_name}"]
}