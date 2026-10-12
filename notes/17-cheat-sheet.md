# 17 · Cheat sheet

## Everyday commands

```bash
terraform init                    # download providers/modules, set up backend
terraform init -upgrade           # move to newer allowed provider versions
terraform init -migrate-state     # after changing backend: copy state over
terraform fmt -recursive          # tidy formatting
terraform validate                # check for mistakes
terraform plan                    # preview changes
terraform plan -out=tfplan        # save the plan
terraform apply                   # make changes (asks for yes)
terraform apply tfplan            # apply exactly a saved plan
terraform apply -auto-approve     # no question (CI only!)
terraform destroy                 # delete everything in this state
terraform output [-raw|-json] [name]
terraform console                 # try expressions live
terraform graph                   # dependency graph (Graphviz format)
terraform providers               # which providers this code uses
terraform version
```

## Variables on the command line

```bash
terraform plan -var "environment=prod"
terraform plan -var-file=prod.tfvars
export TF_VAR_environment=prod
```

## Plan options

```bash
-target=ADDRESS           # only this (emergencies)
-replace=ADDRESS          # force recreate
-refresh-only             # only check for drift
-destroy                  # preview a destroy
-generate-config-out=f.tf # write code for import blocks
-detailed-exitcode        # exit 0 = no changes, 2 = changes (useful in scripts)
```

## State

```bash
terraform state list
terraform state show ADDRESS
terraform state mv FROM TO        # prefer moved {} blocks
terraform state rm ADDRESS        # prefer removed {} blocks
terraform state pull > backup.tfstate
terraform force-unlock LOCK_ID
```

## Workspaces

```bash
terraform workspace list | new NAME | select NAME | show | delete NAME
```

## Plan symbols

`+` create · `~` update · `-` destroy · `-/+` replace (destroy first) · `+/-` replace (create first) · `<=` read

## Code patterns

```hcl
# Provider + versions
terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.0" }
  }
}

# Variable with checks
variable "env" {
  type    = string
  default = "dev"
  validation {
    condition     = contains(["dev", "prod"], var.env)
    error_message = "dev or prod only."
  }
}

# Many named copies
resource "x" "y" {
  for_each = toset(["a", "b"])
  name     = each.key
}

# On/off switch
resource "x" "optional" {
  count = var.enabled ? 1 : 0
}

# Transform
locals {
  upper = [for s in var.list : upper(s)]
  byKey = { for s in var.list : s => length(s) }
}

# Protect
lifecycle {
  prevent_destroy       = true
  create_before_destroy = true
  ignore_changes        = [tags]
}

# Refactor
moved {
  from = a.old
  to   = a.new
}
import {
  to = a.thing
  id = "real-id"
}
removed {
  from = a.thing
  lifecycle { destroy = false }
}

# Module
module "m" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"
}
```

## References

| Write | Means |
|---|---|
| `var.x` | variable |
| `local.x` | local |
| `type.name.attr` | resource attribute |
| `data.type.name.attr` | data source attribute |
| `module.name.output` | module output |
| `each.key` / `each.value` | inside `for_each` |
| `count.index` | inside `count` |
| `self.attr` | inside conditions/provisioners: this resource |
| `path.module` / `path.root` | folder of this module / the root |
| `terraform.workspace` | current workspace name |

## `.gitignore`

```
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
crash.log
*.auto.tfvars        # if they contain secrets
```
(Commit `.terraform.lock.hcl`.)
