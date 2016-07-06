/**
 * The layercake module contains all of the submodules for standing
 * up a modern cloud infrastructure in Amazon.
 *
 * Usage:
 *
 *    module "layercake" {
 *      source      = "github.com/likwid/layercake"
 *      name        = "example"
 *      environment = "sandbox"
 *    }
 *
 */

variable "name" {
  description = "the name of your infrastructure, e.g. \"layercake-example\""
}

variable "environment" {
  description = "the tag for your infrastructure, splitting it into stages e.g. \"prod, staging, sandbox\""
}

variable "key_name" {
  description = "the name of the ssh key to use, e.g. \"internal-key\""
}

variable "domain_name" {
  description = "the internal DNS name to use with services"
  default     = "lc.io"
}

variable "domain_name_servers" {
  description = "the internal DNS servers, defaults to the internal route53 server of the VPC"
  default     = ""
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-east-1"
}

variable "cidr" {
  description = "the CIDR block to provision for the VPC, if set to something other than the default, both internal_subnets and external_subnets have to be defined as well"
  default     = "10.10.0.0/16"
}

variable "internal_subnets" {
  description = "a comma-separated list of CIDRs for internal subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = "10.10.0.0/19,10.10.64.0/19,10.10.128.0/19"
}

variable "external_subnets" {
  description = "a comma-separated list of CIDRs for external subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = "10.10.32.0/20,10.10.96.0/20,10.10.160.0/20"
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both internal_subnets and external_subnets have to be defined as well"
  default     = "us-east-1b,us-east-1c,us-east-1d"
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion"
  default     = "t2.micro"
}

variable "instance_type" {
  description = "Instance type for the management node"
  default     = "m4.large"
}

variable "docker_host_ami" {
  description = "The ami for launching docker hosts"
}

variable "resource_node_security_groups" {
  description = "Allows ingress traffic to resource cluster, defaults to allow traffic from mgmtnode and external elb"
  default     = ""
}

// This is necessary because terraform would delete the s3 bucket otherwise, including all our data
variable "docker_registry_s3_arn" {
  description = "S3 arn of bucket where docker registry data should be stored"
}

module "defaults" {
  source = "./defaults"
  region = "${var.region}"
  cidr   = "${var.cidr}"
}

module "iam_roles" {
  source              = "./iam-roles"
  name                = "${var.name}"
  environment         = "${var.environment}"
  docker_registry_arn = "${var.docker_registry_s3_arn}"
}

module "vpc" {
  source             = "./vpc"
  name               = "${var.name}"
  cidr               = "${var.cidr}"
  internal_subnets   = "${var.internal_subnets}"
  external_subnets   = "${var.external_subnets}"
  availability_zones = "${var.availability_zones}"
  environment        = "${var.environment}"
}

module "dhcp" {
  source  = "./dhcp"
  name    = "${module.dns.name}"
  vpc_id  = "${module.vpc.id}"
  servers = "${coalesce(var.domain_name_servers, module.defaults.domain_name_servers)}"
}

module "dns" {
  source = "./dns"
  name   = "${var.domain_name}"
  vpc_id = "${module.vpc.id}"
}

module "security_groups" {
  source      = "./security-groups"
  name        = "${var.name}"
  vpc_id      = "${module.vpc.id}"
  environment = "${var.environment}"
  cidr        = "${var.cidr}"
}

module "bastion" {
  source               = "./bastion"
  instance_type        = "${var.bastion_instance_type}"
  region               = "${var.region}"
  security_groups      = "${module.security_groups.external_ssh},${module.security_groups.internal_ssh}"
  vpc_id               = "${module.vpc.id}"
  key_name             = "${var.key_name}"
  subnet_id            = "${element(split(",",module.vpc.external_subnets), 0)}"
  environment          = "${var.environment}"
  instance_iam_profile = "${module.iam_roles.describe_profile_name}"
}

module "mgmtnode" {
  source               = "./mgmtnode"
  instance_type        = "${var.instance_type}"
  region               = "${var.region}"
  launch_ami           = "${var.docker_host_ami}"
  instance_iam_profile = "${module.iam_roles.management_node_profile_name}"
  security_groups      = "${module.security_groups.internal_ssh},${module.security_groups.cluster}"
  vpc_id               = "${module.vpc.id}"
  subnet_id            = "${element(split(",",module.vpc.internal_subnets), 0)}"
  key_name             = "${var.key_name}"
  environment          = "${var.environment}"
  internal_dns_zone_id = "${module.dns.zone_id}"
  internal_dns_name    = "${module.dns.name}"
}

module "consul_servers" {
  source                 = "./consul-servers"
  instance_type          = "${var.instance_type}"
  region                 = "${var.region}"
  security_groups        = "${module.security_groups.cluster},${module.mgmtnode.mgmt_security_group}"
  vpc_id                 = "${module.vpc.id}"
  vpc_cidr               = "${var.cidr}"
  key_name               = "${var.key_name}"
  availability_zones     = "${module.vpc.availability_zones}"
  subnet_ids             = "${module.vpc.internal_subnets}"
  instance_iam_profile   = "${module.iam_roles.docker_host_profile_name}"
  environment            = "${var.environment}"
  mgmt_security_group    = "${module.mgmtnode.mgmt_security_group}"
  cluster_security_group = "${module.security_groups.cluster}"
  launch_ami             = "${var.docker_host_ami}"
}

module "nomad_resource_nodes" {
  source                 = "./nomad-resource-nodes"
  name                   = "${var.name}"
  instance_type          = "${var.instance_type}"
  region                 = "${var.region}"
  vpc_id                 = "${module.vpc.id}"
  vpc_cidr               = "${var.cidr}"
  key_name               = "${var.key_name}"
  availability_zones     = "${module.vpc.availability_zones}"
  subnet_ids             = "${module.vpc.internal_subnets}"
  elb_subnet_ids         = "${module.vpc.external_subnets}"
  environment            = "${var.environment}"
  instance_iam_profile   = "${module.iam_roles.docker_host_profile_name}"
  mgmt_security_group    = "${module.mgmtnode.mgmt_security_group}"
  elb_security_group     = "${module.security_groups.external_elb}"
  cluster_security_group = "${module.security_groups.cluster}"
  launch_ami             = "${var.docker_host_ami}"
}

