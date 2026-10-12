# 13 · Changing things safely: import, moved, removed

Your code will change shape over time: renaming, splitting into modules,
taking over things made by hand. These three blocks let you do it **without
deleting and recreating** real infrastructure.

## `import` — take over something that already exists

Someone created a bucket by hand. You want Terraform to manage it.

1. Write the resource block:

```hcl
resource "aws_s3_bucket" "legacy" {
  bucket = "old-handmade-bucket"
}
```

2. Add an `import` block saying "this block = that real thing":

```hcl
import {
  to = aws_s3_bucket.legacy
  id = "old-handmade-bucket"     # the real ID — each resource's docs say what format
}
```

3. `terraform plan` shows `will be imported`. Adjust your code until the plan
   shows **no other changes**, then `apply`. Delete the `import` block afterwards.

> ⚠️ If your code doesn't match the real thing, the plan can say
> `must be replaced` / `this will destroy the imported resource`. Never apply that —
> fix the code until the plan shows **only** the import.
>
> Not every resource type supports import. The resource's docs page has an
> "Import" section at the bottom if it does.

### Let Terraform write the code for you

```bash
terraform plan -generate-config-out=generated.tf
```

With an `import` block but **no** resource block, Terraform writes a starting
version of the code into `generated.tf`. Tidy it up and keep it.

> Old way: `terraform import aws_s3_bucket.legacy old-handmade-bucket` (a
> command). The block is better: it shows up in the plan and can be reviewed.

## `moved` — rename without destroying

You rename a resource or move it into a module:

```hcl
# before
resource "local_file" "hello" { ... }

# after
resource "local_file" "greeting" { ... }
```

Terraform thinks: "`hello` is gone → destroy it; `greeting` is new → create it."
For a database that's a disaster. Tell it they're the same thing:

```hcl
moved {
  from = local_file.hello
  to   = local_file.greeting
}
```

Now the plan says `has moved to local_file.greeting` — no destroy, no create.

Works for modules and `for_each` keys too:

```hcl
moved {
  from = aws_s3_bucket.logs
  to   = module.storage.aws_s3_bucket.this
}

moved {
  from = local_file.server[0]
  to   = local_file.server["web"]
}
```

Keep `moved` blocks around for a while (especially in shared modules) so
everyone's state gets updated, then clean them up.

## `removed` — stop managing, but don't delete

You want Terraform to **forget** something but leave it running (e.g. handing
it to another team):

```hcl
removed {
  from = aws_s3_bucket.legacy

  lifecycle {
    destroy = false     # forget it, don't delete it
  }
}
```

Delete the resource block itself, add this, apply. The bucket stays in AWS;
Terraform no longer tracks it.

## Which one do I need?

| Situation | Use |
|---|---|
| Thing exists, Terraform doesn't know it | `import` block |
| Terraform knows it, but under a different name/place in code | `moved` block |
| Terraform should stop knowing it, but keep it alive | `removed` block with `destroy = false` |
| Terraform should delete it | just delete the resource block |

## Try it

[`examples/13-refactor`](../examples/13-refactor/README.md) walks you through
renaming a resource with `moved`, importing something that already exists
(including the classic "import then accidentally destroy" trap), and letting go with `removed`.

## Remember

- Renaming in code = destroy + create, **unless** you add a `moved` block.
- `import` blocks bring existing things under Terraform, and can generate code.
- `removed` + `destroy = false` = let go without deleting.
- Always check the plan says "moved"/"imported", not "destroy".
