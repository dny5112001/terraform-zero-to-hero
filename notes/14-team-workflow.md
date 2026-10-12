# 14 · Working in a team

Alone, `terraform apply` from your laptop is fine. In a team, you need rules
so people don't step on each other or break production.

## The four must-haves

### 1. Remote state with locking

Covered in chapter 07. Everyone shares one notebook, and only one person can
write at a time:

```hcl
terraform {
  backend "s3" {
    bucket       = "acme-terraform-state"
    key          = "notes-app/prod/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

The state bucket itself: versioning on (so you can recover an old state),
encryption on, public access blocked, and only a few people/roles can read it.

### 2. Everything through git and pull requests

```
branch → change .tf → push → PR
         CI runs: fmt check, validate, lint, security scan, terraform plan
         plan is posted on the PR
         teammate reviews the CODE and the PLAN
merge → CI runs terraform apply (the reviewed plan)
```

**Nobody runs `apply` on production from their laptop.** The pipeline does it.
This gives you a history of every change, who approved it, and what the plan was.

### 3. Pipeline logins, not personal keys

The CI system should log into the cloud with short-lived credentials, e.g.
**GitHub Actions OIDC → an AWS IAM role**. No long-lived secret keys stored in CI.

Give the "plan" job read-only permissions and the "apply" job write permissions,
and require approval before the apply job runs for production.

### 4. Keep secrets out of code and state where you can

- Never put passwords in `.tf` files or committed `.tfvars`.
- Read secrets at apply time from a secret store: AWS Secrets Manager, SSM Parameter Store, HashiCorp Vault.
- Better still: let the service **generate and keep** its own secret (e.g. `manage_master_user_password = true` on AWS RDS), so Terraform never sees it.
- Terraform 1.10+ supports **ephemeral** values and 1.11+ **write-only** arguments — values used during a run but *never saved to state*. Use them for passwords when your provider supports them.

## A sample GitHub Actions pipeline (shape only)

```yaml
name: terraform
on:
  pull_request:
  push:
    branches: [main]

permissions:
  id-token: write        # allows OIDC login to AWS
  contents: read
  pull-requests: write

jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/terraform-plan
          aws-region: ap-south-1
      - run: terraform fmt -check -recursive
      - run: terraform init -input=false
      - run: terraform validate
      - run: terraform plan -input=false -out=tfplan
      # post the plan as a PR comment, upload tfplan as an artifact

  apply:
    if: github.ref == 'refs/heads/main'
    needs: plan
    environment: production    # GitHub "environment" with required reviewers
    runs-on: ubuntu-latest
    steps:
      # same setup, with the "terraform-apply" role
      - run: terraform apply -input=false tfplan
```

Ready-made tools that do this for you: **Atlantis** (plan/apply from PR comments),
**HCP Terraform**, **Spacelift**, **env0**, **Terrateam**.

## Team habits

- **Small PRs.** A plan with 3 changes gets read properly; one with 300 doesn't.
- **Pin versions** of Terraform (`required_version`), providers and modules.
- **Run plans regularly** (e.g. nightly) to catch drift early.
- **Write down ownership**: which team owns which state/folder.
- **Never edit state by hand.** Use the commands and blocks from chapters 07 and 13.

## Remember

- Remote state + locking, PR-based changes, pipeline applies, no secrets in code.
- Review **both** the code and the plan.
- Production applies come from the pipeline, with approval.
