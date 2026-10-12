# 05 · Resources and how they connect

## A resource = one thing Terraform creates and looks after

```hcl
resource "aws_s3_bucket" "photos" {
  bucket = "my-photos-2026"
}
```

- `aws_s3_bucket` — the **type** (what kind of thing). Fixed by the provider.
- `photos` — the **name** you give it *inside Terraform*. Only used in your code.
- `bucket = ...` — the **arguments** (settings).

Its full address is `aws_s3_bucket.photos`. You'll see addresses in plans and
in commands.

> The Terraform name (`photos`) and the real name in AWS (`my-photos-2026`) are
> different things. Renaming `photos` in code makes Terraform think it's a new
> thing — chapter 13 shows how to rename safely.

## Arguments vs attributes

- **Arguments** = what *you* set (`bucket = "my-photos-2026"`).
- **Attributes** = what you can *read back* after it's created, including
  things AWS decides (`aws_s3_bucket.photos.arn`, `.id`).

The docs page for each resource has both lists: "Argument Reference" and
"Attribute Reference".

## Dependencies: the order things get built in

You never write "do A first, then B". Terraform figures out the order from
your **references**:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "app" {
  vpc_id     = aws_vpc.main.id       # <- this reference creates a dependency
  cidr_block = "10.0.1.0/24"
}
```

Because the subnet uses `aws_vpc.main.id`, Terraform knows the VPC must exist
first. It builds a **dependency graph** (a map of "what needs what"):

```
aws_vpc.main ──► aws_subnet.app
```

- **Creating:** follows the arrows (VPC, then subnet).
- **Destroying:** goes backwards (subnet, then VPC).
- **Things that don't depend on each other** are created **at the same time**, which is why Terraform is fast.

See the graph yourself: `terraform graph` (paste the output into an online
Graphviz viewer).

## `depends_on` — when there's no reference

Sometimes B needs A, but B's settings don't mention A. Then say it directly:

```hcl
resource "aws_instance" "app" {
  # ...
  depends_on = [aws_iam_role_policy.app_permissions]
}
```

Use this rarely. A real reference is almost always better because it's clearer.

## "Known after apply"

In a plan you'll often see:

```
+ arn = (known after apply)
```

Some values (IDs, IP addresses) don't exist until the thing is actually
created. Terraform shows a placeholder and fills it in during apply.

## Meta-arguments: settings every resource has

These work on **any** resource, whatever the provider:

| Meta-argument | What it does | Chapter |
|---|---|---|
| `depends_on` | force an order | here |
| `count` | make N copies | 10 |
| `for_each` | make one copy per item in a list/map | 10 |
| `provider` | choose a specific provider (alias) | 04 |
| `lifecycle` | special rules (don't delete, replace carefully, ignore changes) | 08 |

## Try it

[`examples/05-dependencies`](../examples/05-dependencies/main.tf) creates a random
password, then a file that uses it, then a second file that uses the first.
1. Run `terraform plan` and notice nothing tells it the order — it works it out.
2. Run `terraform graph` and look at the arrows.
3. Run `terraform apply` — see the creation order in the output.

## Remember

- Address = `type.name`. The name is only inside Terraform.
- **References create order automatically.** `depends_on` is the backup plan.
- Independent things are built in parallel.
