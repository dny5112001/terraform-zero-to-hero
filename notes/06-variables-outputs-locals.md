# 06 · Variables, outputs and locals

Think of a Terraform folder like a **function** in programming:

```
   variables  ──►  [ your .tf code ]  ──►  outputs
   (inputs)          locals = scratch notes   (results)
```

## Variables — inputs

Instead of hard-coding values, make them inputs:

```hcl
variable "environment" {
  description = "Which environment this is"
  type        = string
  default     = "dev"            # used if nobody sets a value
}
```

Use it with `var.`:

```hcl
content = "This is ${var.environment}"
```

A variable **without a default** is required — Terraform asks you for it.

### Types and checks

```hcl
variable "instance_count" {
  type    = number
  default = 2

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 5
    error_message = "Pick between 1 and 5 instances."
  }
}

variable "tags" {
  type    = map(string)
  default = { team = "web" }
}

variable "server" {
  type = object({
    name = string
    size = optional(string, "small")   # optional, with a default
  })
}
```

`validation` stops bad values **before** anything is built. Use it generously.

### Hiding secrets in the output

```hcl
variable "db_password" {
  type      = string
  sensitive = true      # shows (sensitive value) instead of the password in plans
}
```

⚠️ `sensitive` only hides it on screen. It's still saved in the state file (chapter 07).

### Ways to give a variable a value

From **lowest** to **highest** priority (later ones win):

1. `default` in the variable block
2. Environment variable: `export TF_VAR_environment=prod`
3. `terraform.tfvars` file (loaded automatically)
4. `*.auto.tfvars` files (loaded automatically)
5. `-var-file=prod.tfvars` on the command line
6. `-var "environment=prod"` on the command line

A `.tfvars` file is just values:

```hcl
# prod.tfvars
environment    = "prod"
instance_count = 3
```

```bash
terraform apply -var-file=prod.tfvars
```

## Outputs — results

Show useful values after apply, or pass them to other code:

```hcl
output "website_url" {
  description = "Open this in your browser"
  value       = "https://${aws_s3_bucket.site.bucket}.s3.amazonaws.com"
}

output "db_password" {
  value     = random_password.db.result
  sensitive = true
}
```

```bash
terraform output                  # show all
terraform output website_url      # one value
terraform output -raw website_url # without quotes (good for scripts)
terraform output -json            # everything as JSON
```

Outputs are also how a **module** gives values back (chapter 11) and how one
project reads another project's results (chapter 12).

## Locals — named shortcuts

When you repeat the same expression, give it a name:

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    project     = var.project
    environment = var.environment
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.name_prefix}-logs"
  tags   = local.common_tags
}
```

Note: the block is `locals` (plural), but you use them with `local.` (singular).

**Variable or local?** If someone outside should be able to change it → variable.
If it's just calculated inside to keep code tidy → local.

## Try it

[`examples/06-variables`](../examples/06-variables/):
1. `terraform apply` — uses defaults.
2. `terraform apply -var-file=prod.tfvars` — see the values change.
3. `terraform apply -var instance_count=9` — watch the validation stop you.
4. `terraform output` and `terraform output -raw summary`.

## Remember

- **variables** = inputs (`var.x`), **outputs** = results, **locals** = shortcuts (`local.x`).
- Add `type`, `description` and `validation` — future you will thank you.
- `sensitive` hides values on screen, not in state.
