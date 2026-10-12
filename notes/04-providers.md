# 04 · Providers — the translators

## What is a provider?

Terraform itself doesn't know how to make an AWS server or a GitHub repo.
**Providers** do. A provider is a plugin that translates your Terraform code
into calls to one service.

```
your .tf code ──► Terraform core ──► AWS provider ──────► AWS
                                 ├─► GitHub provider ───► GitHub
                                 └─► local provider ────► files on your laptop
```

Think of Terraform as a manager who speaks one language, and providers as
translators for each country.

There are thousands on the [Terraform Registry](https://registry.terraform.io/browse/providers).
Every resource type starts with its provider's name: `aws_s3_bucket` → AWS
provider, `local_file` → local provider, `github_repository` → GitHub provider.

## Asking for a provider

```hcl
terraform {
  required_version = ">= 1.9"          # which Terraform versions this code works with

  required_providers {
    aws = {
      source  = "hashicorp/aws"        # where to download it: <publisher>/<name>
      version = "~> 6.0"               # which versions are OK
    }
  }
}
```

### Version rules in plain words

| Write | Means |
|---|---|
| `"= 6.2.0"` | exactly 6.2.0 |
| `">= 6.0"` | 6.0 or anything newer (risky: a future 7.0 may break you) |
| `"~> 6.0"` | 6.anything, but **not** 7.0 — the usual choice |
| `"~> 6.2.1"` | 6.2.anything (only bug-fix updates) |

`~>` is called the "pessimistic" operator: allow safe updates, block big ones.

## The lock file

`terraform init` writes `.terraform.lock.hcl` with the **exact** version it
picked, plus checksums (fingerprints) to prove the download wasn't tampered with.
**Commit it.** Then your teammate and your CI pipeline use the very same version.

To deliberately move to newer versions (within your rules):

```bash
terraform init -upgrade
```

## Configuring a provider

Most providers need settings, like which region or which account:

```hcl
provider "aws" {
  region = "ap-south-1"

  default_tags {                   # added to every AWS resource automatically
    tags = { project = "notes", managed_by = "terraform" }
  }
}
```

### Logging in (credentials) — never put them in code

Bad:
```hcl
provider "aws" {
  access_key = "AKIA..."   # ❌ ends up in git, in plain text
}
```

Good: let the provider find them in the environment:
```bash
export AWS_PROFILE=my-profile        # or aws sso login / aws login
terraform plan
```

Every provider documents where it looks for credentials (environment variables,
config files, etc.). Use those.

## Two of the same provider (aliases)

Need resources in two AWS regions? Give the second one an `alias`:

```hcl
provider "aws" {
  region = "ap-south-1"            # the default one
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

resource "aws_s3_bucket" "backup" {
  provider = aws.us                # use the second one
  bucket   = "my-backup"
}
```

## Try it

[`examples/04-providers`](../examples/04-providers/main.tf) uses two providers
(`random` and `local`) together. Run `terraform init` and look inside
`.terraform/providers/` to see the downloaded plugins, then open
`.terraform.lock.hcl`.

## Remember

- Providers are plugins that talk to one service each.
- Pin them with `~>` and **commit the lock file**.
- Never write passwords or keys in provider blocks.
