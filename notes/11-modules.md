# 11 · Modules — reusable building blocks

## What is a module?

**Any folder of `.tf` files is a module.** The folder you run `terraform apply`
in is the **root module**. When it uses another folder, that's a **child module**.

A module is like a **function**, or a LEGO piece:
- **Inputs** = its variables
- **Inside** = its resources
- **Return values** = its outputs

Why bother?
- **Don't repeat yourself.** Write "a secure storage bucket" once, use it 20 times.
- **Hide the details.** Users set 3 inputs instead of learning 40 settings.
- **Bake in good habits.** Encryption, tags and backups are on by default for everyone.

## Make one

```
examples/11-modules/
├── main.tf                  # root module — uses the child
└── modules/
    └── greeting-file/       # child module
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

`modules/greeting-file/variables.tf`:
```hcl
variable "name"     { type = string }
variable "greeting" {
  type    = string
  default = "Hello"
}
```

`modules/greeting-file/main.tf`:
```hcl
resource "local_file" "this" {
  filename = "${path.root}/out/${var.name}.txt"
  content  = "${var.greeting}, ${var.name}!"
}
```

`modules/greeting-file/outputs.tf`:
```hcl
output "path" { value = local_file.this.filename }
```

## Use it

```hcl
module "alice" {
  source = "./modules/greeting-file"   # where the module lives
  name   = "alice"                     # its inputs
}

module "bob" {
  source   = "./modules/greeting-file"
  name     = "bob"
  greeting = "Namaste"
}

output "files" {
  value = [module.alice.path, module.bob.path]   # its outputs
}
```

Run `terraform init` after adding a module — Terraform needs to register it.

Addresses now include the module: `module.alice.local_file.this`.

Modules work with `for_each` too:

```hcl
module "greeting" {
  for_each = toset(["alice", "bob", "carol"])
  source   = "./modules/greeting-file"
  name     = each.key
}
```

## Where modules can come from

```hcl
source = "./modules/network"                                 # local folder
source = "terraform-aws-modules/vpc/aws"                     # public Terraform Registry
source = "git::https://github.com/acme/tf-modules.git//vpc?ref=v1.4.0"  # a git repo, at a tag
```

Registry and git modules should **always pin a version**:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"
  # ...
}
```

The public registry has excellent community modules (VPC, EKS, RDS...). Read
their code before using them — you're trusting it with your infrastructure.

## Good module habits

1. **Small and focused.** "A storage bucket with backups" — not "the whole company".
2. **Few required inputs, sensible defaults.**
3. **Describe and validate** every variable.
4. **Output what callers need** (IDs, names, URLs).
5. **Don't put `provider` blocks inside child modules** — let the root module configure providers and pass them down. Declare what you need in `required_providers` only.
6. **Version them** (git tags) once others depend on them, and write a short README.
7. **Don't wrap a single resource** in a module just because. If it doesn't simplify anything, skip it.

## Try it

[`examples/11-modules`](../examples/11-modules/):
1. Apply and look at `out/`.
2. `terraform state list` — see the `module.` prefixes.
3. Add a `module "carol"` using a different greeting, `init`, apply.
4. Add a new input `shout` (bool) to the module that makes the text upper-case. Hint: `var.shout ? upper(x) : x`.

## Remember

- Every folder is a module; modules = inputs → resources → outputs.
- `source` says where it lives; pin `version` for remote ones.
- Keep modules small and opinionated, with good defaults.
