# 09 · Data sources — looking things up

A **resource** *creates and manages* something.
A **data source** only *reads* something that already exists. It never changes anything.

```
resource  = "build me a house"
data      = "tell me the address of the house next door"
```

## Example: find the newest Ubuntu image

You don't want to hard-code an image ID that changes every month:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]   # Canonical, the company behind Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id     # use what we looked up
  instance_type = "t3.micro"
}
```

Note the `data.` at the front when you use it.

## Common reasons to use data sources

| Need | Data source example |
|---|---|
| Use something another team created (a network, a DNS zone) | `data "aws_vpc"`, `data "aws_route53_zone"` |
| Find the current account/region | `data "aws_caller_identity"`, `data "aws_region"` |
| Read a file from disk | `data "local_file"` |
| Build an access policy safely (no hand-written JSON) | `data "aws_iam_policy_document"` |
| Read another Terraform project's outputs | `data "terraform_remote_state"` (chapter 12) |
| Run a small script and use its result | `data "external"` (use sparingly) |

## When are data sources read?

Usually during `plan`. If a data source depends on something not yet created,
Terraform waits and reads it during `apply` — you'll see `<= read (data resources)`
in the plan.

## Data source vs hard-coding

```hcl
vpc_id = "vpc-0a1b2c3d"                    # ❌ breaks in another account/region
vpc_id = data.aws_vpc.shared.id            # ✅ looked up wherever you run it
```

## Try it

[`examples/09-data-sources`](../examples/09-data-sources/main.tf) reads a file
from disk with `data "local_file"`, counts its lines, and writes a report.
Edit `input.txt`, then plan again — the data source picks up the new content
without you changing any code.

## Remember

- `data` = read-only lookup; `resource` = create and manage.
- Use `data.<type>.<name>.<attribute>`.
- Prefer lookups over hard-coded IDs.
