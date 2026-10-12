# 12 · Organising a real project

Learning projects are one folder. Real ones have **several environments**
(dev, staging, prod) and **many pieces** (network, database, apps). How you
arrange them decides how safe and pleasant Terraform is to use.

## Problem 1: one giant folder

Everything in one place = one huge state:
- `plan` takes ages.
- A typo in the app code can produce a plan that touches the database.
- Everyone needs permission for everything.

The amount of damage one mistake can do is called the **blast radius**. Keep it small.

## Solution: split into layers

Split by **how often things change** and **who owns them**:

```
infra/
├── 01-network/     # VPC, subnets      — changes rarely, owned by platform team
├── 02-cluster/     # Kubernetes / DBs  — changes sometimes
├── 03-data/        # buckets, queues
└── 04-apps/        # app deployments   — changes daily
```

Each folder has **its own state**. A bad app change can't delete the network.

This is exactly how the [k8s-terraform-lab](https://github.com/dny5112001/k8s-terraform-lab)
is built (`stages/01-cluster` → `04-app`).

### Passing values between layers

Layer 04 needs the cluster name from layer 02. Two ways:

**a) Read the other layer's outputs from its state:**

```hcl
data "terraform_remote_state" "cluster" {
  backend = "s3"
  config = {
    bucket = "my-company-terraform-state"
    key    = "prod/02-cluster/terraform.tfstate"
    region = "ap-south-1"
  }
}

locals {
  cluster_name = data.terraform_remote_state.cluster.outputs.cluster_name
}
```

Simple, but it needs read access to that whole state file (which may contain secrets).

**b) Look the thing up with a normal data source** (often better):

```hcl
data "aws_eks_cluster" "main" {
  name = "prod-main"
}
```

Or share values through a parameter store (e.g. AWS SSM Parameter Store).

## Problem 2: dev, staging and prod

You want the **same code** with **different sizes and names**.

### Option A — one folder per environment (most common, most clear)

```
modules/
└── app-stack/                # all the real resources, written once
envs/
├── dev/
│   ├── main.tf               # module "stack" { source = "../../modules/app-stack", size = "small" }
│   └── backend.tf            # key = "dev/terraform.tfstate"
├── staging/
└── prod/
    ├── main.tf               # same module, size = "large", replicas = 3
    └── backend.tf            # key = "prod/terraform.tfstate"
```

- ✅ You can *see* exactly what prod has. Separate state and permissions per env.
- ✅ You can roll out a module change to dev first, then prod.
- ❌ A little repetition in the small env files (that's fine).

### Option B — workspaces

One folder, multiple states, selected by name:

```bash
terraform workspace new staging
terraform workspace select staging
terraform apply -var-file=staging.tfvars
```

Code can read `terraform.workspace`:

```hcl
instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"
```

- ✅ Quick for temporary copies (e.g. one environment per feature branch).
- ❌ Easy to apply to the wrong one — nothing on screen tells you which you're in.
- ❌ Same backend and permissions for all — you can't lock prod down separately.

**Recommendation:** folders per environment for dev/staging/prod; workspaces
only for short-lived copies.

### Option C — tools on top

- **Terragrunt** — a wrapper that removes repetition across many env folders.
- **HCP Terraform / Terraform Enterprise** — HashiCorp's hosted service: remote runs, state, approvals, policies.
- **Terraform Stacks** — HashiCorp's newer feature for deploying the same set of components many times (works with HCP Terraform).

Learn plain Terraform first. Add these when the repetition actually hurts.

## A naming and tagging habit

```hcl
locals {
  name = "${var.project}-${var.environment}"     # e.g. notes-prod
  tags = {
    project     = var.project
    environment = var.environment
    owner       = "platform-team"
    managed_by  = "terraform"
  }
}
```

Consistent names and tags make the cloud bill, searching and clean-up much easier.

## Remember

- **Split state by layer** to keep the blast radius small.
- **One folder per environment**, sharing modules. Workspaces for temporary copies.
- Pass values between layers with outputs (`terraform_remote_state`) or lookups.
