# 13 · Refactor practice

## Part A — rename with `moved`

1. `terraform init && terraform apply` (creates `hello.txt`).
2. In `main.tf`, rename `local_file.hello` to `local_file.greeting`. Run `terraform plan`:
   you'll see **1 to add, 1 to destroy**. That's the danger.
3. Add this block to `main.tf` and plan again:

   ```hcl
   moved {
     from = local_file.hello
     to   = local_file.greeting
   }
   ```

   Now the plan says `has moved to local_file.greeting` and **0 to destroy**. Apply.

## Part B — take over an existing thing with `import`

Pretend someone already created a random string by hand, and its value is `existing1234`.
(Not every resource supports import — the docs page says so near the bottom.
`local_file` doesn't; `random_string` does, which is why we use it here.)

1. Add to `main.tf`:

   ```hcl
   resource "random_string" "legacy" {
     length  = 12
     special = false
   }

   import {
     to = random_string.legacy
     id = "existing1234"
   }
   ```

2. `terraform plan`. Look closely:

   ```
   # random_string.legacy must be replaced
   # Warning: this will destroy the imported resource
   ~ special = true -> false # forces replacement
   ```

   **This is the classic import mistake.** Your code says `special = false`, but the
   real thing doesn't match, so Terraform would import it *and then destroy it*.

3. Fix the code to match reality: delete the `special = false` line. Plan again:

   ```
   # random_string.legacy will be imported
   Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
   ```

   Only now is it safe. Apply. Run `terraform state list` — it's managed now.
   Remove the `import` block afterwards.

## Part C — let go with `removed`

1. Delete the `random_string.legacy` resource block and add:

   ```hcl
   removed {
     from = random_string.legacy
     lifecycle {
       destroy = false
     }
   }
   ```

2. `terraform plan` says *"will no longer be managed by Terraform, but will not be destroyed"*.
   Apply. `terraform state list` no longer shows it.

## The lesson

Import, moved and removed are only safe when the **plan shows exactly what you expect**:
"imported", "has moved", "no longer managed" — and **0 to destroy**.
