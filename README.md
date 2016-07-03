# Layer Cake

#### Modern cloud automation using Terraform, opinionated fork of [Segment Stack](github.com/segmentio/stack)

# Getting started

### AMI baking

```
# VPC_ID=vpc-123456 SUBNET_ID=subnet-123456 make build-trusty
```

### Orchestration

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
# terraform plan
# terraform apply
# terraform output -module="layercake.bastion"
```

### Provisioning

```
# ssh ubuntu@bastion_external_ip -oForwardAgent=yes
# ssh management.lc.io -oForwardAgent=yes
# git clone git@github.com:likwid/layercake
# cd layercake/ansible
# ansible-playbook playbooks/consul-servers/playbook.yml
# ansible-playbook playbooks/nomad-servers/playbook.yml
```

