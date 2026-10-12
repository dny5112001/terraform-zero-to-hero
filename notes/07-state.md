# 07 · State — Terraform's memory

**If you understand state, you understand Terraform.** Most scary Terraform
problems are really state problems.

## What is state?

After `apply`, Terraform writes `terraform.tfstate`. It's a JSON file that
records **every real thing Terraform created**, linked to its name in your code:

```
In your code              In state                         In the real world
aws_s3_bucket.photos  →   id: "my-photos-2026", arn: ...  →   the actual bucket
```

It's like a **notebook** where Terraform writes "I made this bucket, and I
called it `photos`".

## Why does Terraform need a notebook?

Without it, Terraform couldn't tell:
- **"Is this bucket mine?"** Your AWS account might have 100 buckets. State says which ones *this* code owns.
- **"What did I make last time?"** If you delete a resource block from your code, state is how Terraform knows something should be deleted from AWS.
- **Speed:** it remembers IDs, so it doesn't have to search everything each time.

## What happens during `plan`

```
1. Read your code              → what you WANT
2. Read state                  → what Terraform THINKS exists
3. Ask the provider (refresh)  → what REALLY exists right now
4. Compare and show the differences
```

## Drift: when reality changes behind Terraform's back

Someone logs into the AWS website and changes a setting by hand. Now reality
doesn't match your code. That's **drift**.

Next `terraform plan` notices and offers to put it back the way your code says.

```bash
terraform plan -refresh-only    # just show what drifted; change nothing
terraform apply -refresh-only   # accept reality: update state to match, don't touch AWS
```

**Rule of thumb:** once Terraform manages something, change it only through Terraform.

## State is sensitive!

State contains **every value**, including passwords and keys — even ones
marked `sensitive`. Treat the state file like a password file:
- Never commit it to git.
- Store it somewhere private and encrypted (next section).
- Limit who can read it.

## Local vs remote state

By default, state is a file on your laptop. Fine for learning, bad for teams:
- Your teammate doesn't have your file → their Terraform thinks nothing exists and tries to create everything again.
- Your laptop dies → the notebook is gone.
- Two people run `apply` at the same time → they overwrite each other.

The fix is **remote state**: store it in shared storage, configured in a **backend**:

```hcl
terraform {
  backend "s3" {
    bucket       = "my-company-terraform-state"
    key          = "notes-app/prod/terraform.tfstate"   # path inside the bucket
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true      # locking: only one person can apply at a time
  }
}
```

> Older guides use a DynamoDB table for locking. Since Terraform 1.10,
> `use_lockfile = true` locks with a small file in the same S3 bucket instead — simpler.

Other backends: `gcs` (Google), `azurerm` (Azure), HCP Terraform (HashiCorp's service), `local` (the default).

After adding or changing a backend:

```bash
terraform init -migrate-state    # copies your existing state to the new place
```

## Locking — one at a time

While someone runs `apply`, the backend holds a **lock**. If you try at the
same time you'll get "Error acquiring the state lock". **Wait** — don't force it.

If a run crashed and left a stale lock (and you're *sure* nobody is running):

```bash
terraform force-unlock <LOCK_ID>
```

## State commands (look, don't edit the file by hand)

```bash
terraform state list                          # everything Terraform tracks
terraform state show local_file.hello         # all details of one thing
terraform state mv  local_file.a local_file.b # rename in state (prefer "moved" blocks, ch. 13)
terraform state rm  local_file.hello          # forget it — the real thing is NOT deleted
terraform state pull > backup.tfstate         # download a copy (good before risky work)
```

`state rm` is useful when you want Terraform to *stop managing* something without
deleting it. (The modern way is a `removed` block — chapter 13.)

## Try it

In [`examples/07-state`](../examples/07-state/):
1. `terraform apply`, then open `terraform.tfstate` in an editor. Find the password — notice it's readable in plain text.
2. `terraform state list` and `terraform state show random_password.db`.
3. Edit `managed.txt` by hand (drift!). Run `terraform plan` — Terraform wants to fix it.
4. `terraform state rm local_file.managed`, then `terraform plan`. Terraform forgot the file and now wants to create it again — even though it exists. That's what "state is the notebook" means.

## Remember

- State = Terraform's notebook linking your code to real things.
- It holds secrets. Never commit it. In teams, use a **remote backend with locking**.
- Change managed things only through Terraform, or you get drift.
