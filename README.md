# Layer Cake

#### Modern cloud automation using Terraform, opinionated fork of [Segment Stack](https://github.com/segmentio/stack)

### Getting started

#### Pre-requisites

This only works on OS X for now

```
make install
```

#### Baking

AMI Baking assumes you have an existing vpc, subnet that you can spin up a Packer Builder instance. This can be a default vpc, and public subnet.

```
# VPC_ID=vpc-123456 SUBNET_ID=subnet-123456 make build-trusty
```

#### Orchestration

Write the following to a file named main.tf in a directory:

```
variable "region" {
    description = "Where to create the AWS resources"
    default     = "us-east-1"
}

module "layercake" {
    source      = "github.com/likwid/layercake"
    name        = "layercake-example"
    environment = "sandbox"
    region      = "${var.region}"
    key_name    = "sumnurv"
}

provider "aws" {
    region = "${var.region}"
}
```

Inside directory where main.tf resides:

```
# terraform get
# terraform plan
# terraform apply
# terraform output -module="layercake.bastion"
```

Note: If you experience errors while executing terraform apply, just apply again, it is idempotent.

#### Provisioning

```
# ssh ubuntu@bastion_external_ip -oForwardAgent=yes
# ssh management.lc.io -oForwardAgent=yes
# git clone git@github.com:likwid/layercake
# cd layercake/tools/ansible
# ansible-playbook playbooks/nomad-consul-servers/playbook.yml
# ansible-playbook playbooks/nomad-consul-agents/playbook.yml
```
