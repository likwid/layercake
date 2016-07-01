# Layer Cake

## Modern cloud automation using Terraform, opinionated fork of Segment Stack

## Inspired by and borrows heavily from [Segment Stack](github.com/segmentio/stack)

# Getting started

```
variable "region" {
  description = "Where to create the AWS resources"
  default     = "us-east-1"
}

module "layercake" {
  source      = "github.com/likwid/layercake"
  name        = "layercake-example"
  environment = "sandbox"
  region      = "us-east-1"
  key_name    = "sumnurv"
}

provider "aws" {
  region = "${var.region}"
}
```

```
# terraform plan
# terraform apply
```
