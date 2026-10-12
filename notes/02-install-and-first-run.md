# 02 · Install and first run

## Install

Mac (Homebrew):

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform version
```

> Use the `hashicorp/tap` version. The plain `brew install terraform` is stuck on an old release.

Also install the **HashiCorp Terraform** extension in VS Code — it colours the code and auto-completes.

## Your first Terraform project

A Terraform project is just **a folder with `.tf` files in it**. Terraform reads
*all* `.tf` files in the folder together, so how you split them is up to you.

Open [`examples/02-first-run/main.tf`](../examples/02-first-run/main.tf):

```hcl
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content  = "Hello from Terraform!"
}
```

In plain words: *"I want a file called hello.txt with this text in it."*

## The four commands you'll use every day

### 1. `terraform init` — get ready

```bash
cd examples/02-first-run
terraform init
```

Downloads the providers (plugins) your code needs into a hidden `.terraform/`
folder, and writes `.terraform.lock.hcl` (a list of the exact versions it got).

Run it: the first time in a folder, and whenever you add a provider or module.

### 2. `terraform plan` — preview, change nothing

```bash
terraform plan
```

```
  # local_file.hello will be created
  + resource "local_file" "hello" {
      + content  = "Hello from Terraform!"
      + filename = "./hello.txt"
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

`+` means "will be created". **Nothing has happened yet.** A plan is a dry run.

### 3. `terraform apply` — make it real

```bash
terraform apply
```

It shows the plan again and asks `Enter a value:`. Type `yes`.
Now `hello.txt` exists. Also, a new file appeared: **`terraform.tfstate`** —
Terraform's memory of what it created (chapter 07).

Run `terraform apply` again: **"No changes."** Terraform sees the file already
matches what you asked for. This is the declarative idea from chapter 01.

### 4. `terraform destroy` — remove everything

```bash
terraform destroy
```

Deletes everything this folder created. `hello.txt` is gone.

## Make a change

1. `terraform apply` again to create the file.
2. Change `content` to `"Hello again!"`.
3. `terraform plan`. You'll see:

```
-/+ resource "local_file" "hello" {
      ~ content = "Hello from Terraform!" -> "Hello again!" # forces replacement
```

`-/+` means "delete and recreate" — this provider can't edit a file in place.
Chapter 08 teaches you to read every symbol.

## Two handy helpers

```bash
terraform fmt        # tidies your code formatting (spacing, alignment)
terraform validate   # checks for typos and mistakes without touching anything
```

Run both before every commit.

## What goes in git, and what doesn't

| File/folder | Commit to git? | Why |
|---|---|---|
| `*.tf` | ✅ yes | your code |
| `.terraform.lock.hcl` | ✅ yes | everyone gets the same provider versions |
| `.terraform/` | ❌ no | downloaded plugins, big, re-creatable with `init` |
| `terraform.tfstate*` | ❌ no | can contain passwords; lives in remote storage in teams (ch. 14) |
| `*.tfvars` with secrets | ❌ no | secrets |

See this repo's [`.gitignore`](../.gitignore).

## Try it

1. Add a second `local_file` resource called `bye` with different text. Plan, apply.
2. Delete `hello.txt` by hand (`rm hello.txt`), then run `terraform plan`. What does Terraform want to do? (It notices it's missing and recreates it.)
3. Destroy everything when done.

## Remember

`init` once → `plan` to look → `apply` to do → `destroy` to clean up.
