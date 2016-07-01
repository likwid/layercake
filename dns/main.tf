/**
 * The dns module creates a local route53 zone that serves as internal DNS
 *
 * Usage:
 *
 *    module "dns" {
 *      source = "github.com/likwid/layercake"
 *      name   = "layercake.local"
 *    }
 *
 */

variable "name" {
  description = "Zone name, e.g layercake.local"
}

variable "vpc_id" {
  description = "The VPC ID (omit to create a public zone)"
  default     = ""
}

resource "aws_route53_zone" "main" {
  name    = "${var.name}"
  vpc_id  = "${var.vpc_id}"
  comment = ""
}

// The domain name.
output "name" {
  value = "${var.name}"
}

// The zone ID.
output "zone_id" {
  value = "${aws_route53_zone.main.zone_id}"
}

// A comma separated list of the zone name servers.
output "name_servers" {
  value = "${join(",",aws_route53_zone.main.name_servers)}"
}
