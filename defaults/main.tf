/**
 * This module is used to set configuration defaults for the AWS infrastructure.
 * Helper module for layercake
 *
 * Usage:
 *
 *     module "defaults" {
 *       source = "github.com/likwid/layercake/defaults"
 *       region = "us-east-1"
 *       cidr   = "10.0.0.0/16"
 *     }
 *
 */

variable "region" {
  description = "The AWS region"
}

variable "cidr" {
  description = "The CIDR block to provision for the VPC"
}

variable "default_base_trusty_ami" {
  default = {
    us-east-1      = "ami-5f3ff932"
    us-west-1      = "ami-06116566"
    us-west-2      = "ami-9abea4fb"
    eu-west-1      = ""
    eu-central-1   = ""
    ap-northeast-1 = ""
    ap-northeast-2 = ""
    ap-southeast-1 = ""
    ap-southeast-2 = ""
    sa-east-1      = ""
  }
}

variable "default_log_account_ids" {
  default = {
    us-east-1      = "127311923021"
    us-west-2      = "797873946194"
    us-west-1      = "027434742980"
    eu-west-1      = "156460612806"
    eu-central-1   = "054676820928"
    ap-southeast-1 = "114774131450"
    ap-northeast-1 = "582318560864"
    ap-southeast-2 = "783225319266"
    ap-northeast-2 = "600734575887"
    sa-east-1      = "507241528517"
    us-gov-west-1  = "048591011584"
    cn-north-1     = "638102146993"
  }
}

output "domain_name_servers" {
  value = "${cidrhost(var.cidr, 2)}"
}

output "s3_logs_account_id" {
  value = "${lookup(var.default_log_account_ids, var.region)}"
}
