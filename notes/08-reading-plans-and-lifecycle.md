# 08 · Reading a plan like a pro (and protecting things)

The plan is your safety net. **Read every plan before you type `yes`.**
Most real-world disasters happen because someone didn't.

## The symbols

| Symbol | Meaning | Worry level |
|---|---|---|
| `+` | create | 🟢 usually fine |
| `~` | update in place (change a setting, keep the thing) | 🟡 check what changed |
| `-` | destroy | 🔴 is that intended? |
| `-/+` | **replace**: destroy, then create a new one | 🔴🔴 look very carefully |
| `+/-` | replace, but create the new one first | 🟠 safer replace |
| `<=` | read a data source | 🟢 |

The last line is the summary:

```
Plan: 2 to add, 1 to change, 1 to destroy.
```

**Always check the destroy number.** If it's not 0, find out why.

## Why replacements are dangerous

Some settings can't be changed on a live thing. Changing a database's engine,
or a server's base image, means **delete it and make a new one**. Terraform marks that:

```
  # aws_db_instance.main must be replaced
-/+ resource "aws_db_instance" "main" {
      ~ engine = "mysql" -> "postgres" # forces replacement
```

`# forces replacement` points to the exact setting that caused it. For a
database, replacement = **all data lost**. For a server = downtime and a new IP.

## Saving a plan

```bash
terraform plan -out=release.tfplan    # save exactly what will happen
terraform apply release.tfplan        # apply exactly that, no surprises
```

Teams do this in CI: plan, a human reviews it, then apply that exact saved plan.

## Other useful plan options

```bash
terraform plan -target=local_file.hello   # only this one (emergencies only!)
terraform apply -replace=aws_instance.web # force a fresh one even if nothing changed
terraform plan -destroy                   # preview what destroy would remove
```

`-target` is for emergencies. Using it normally leaves your code and reality out of sync.

## `lifecycle` — special rules for a resource

```hcl
resource "aws_db_instance" "main" {
  # ...

  lifecycle {
    prevent_destroy = true
  }
}
```

### `prevent_destroy = true`
Terraform **refuses** any plan that would delete this. Put it on databases,
storage buckets with important data, DNS zones. To really delete, you must
first remove this line — a deliberate, reviewable step.

### `create_before_destroy = true`
For replacements: build the new one **first**, switch over, then delete the
old one. Less downtime. (Names must not clash — often combined with name prefixes.)

### `ignore_changes = [ ... ]`
"Don't fight over these settings." Useful when something else legitimately
changes them:

```hcl
lifecycle {
  ignore_changes = [desired_count]   # the autoscaler changes this; leave it alone
}
```

### `replace_triggered_by = [ ... ]`
"Replace me when *that* changes":

```hcl
lifecycle {
  replace_triggered_by = [terraform_data.app_version]
}
```

### `precondition` / `postcondition`
Sanity checks with a friendly error message:

```hcl
lifecycle {
  precondition {
    condition     = var.environment != "prod" || var.instance_count >= 2
    error_message = "Production needs at least 2 instances."
  }
}
```

## Try it

[`examples/08-lifecycle`](../examples/08-lifecycle/main.tf):
1. Apply it. Then change `content` of `important` and plan — look for `forces replacement`.
2. Run `terraform destroy` — `prevent_destroy` blocks it. Read the error.
3. Change `var.environment` to `prod` with 1 instance: `terraform plan -var environment=prod -var instance_count=1` — the precondition stops you.
4. Remove `prevent_destroy`, then destroy.

## Remember

- Read the summary line. **Destroy count ≠ 0 → find out why.**
- `-/+` and "forces replacement" = the old thing will be deleted.
- Protect precious things with `prevent_destroy`.
