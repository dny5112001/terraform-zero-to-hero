# 01 · What is Terraform?

## The problem

Imagine you need a website on AWS. You log in to the AWS website and click:
create a server, create a database, open some ports, set up a domain name...
50 clicks later it works.

Now:
- Your teammate needs the **same setup** for testing. Do you remember all 50 clicks?
- Someone changed a setting last week. **Who? What was it before?**
- You want to **delete everything** to save money. Did you find every piece?

Clicking around is like cooking without a recipe. It works once, but you can't
repeat it exactly, share it, or undo it.

## The solution: write it down as code

Terraform lets you **describe** what you want in text files:

```hcl
resource "aws_s3_bucket" "photos" {
  bucket = "my-photos-bucket"
}
```

Then you run one command, and Terraform makes it real. That's called
**Infrastructure as Code (IaC)**: your servers, databases, networks etc. are
described in code files, just like your app.

Because it's code, you get all the good things code has:
- **Repeatable** — run it again, get the same thing. Copy it for test/prod.
- **Reviewable** — teammates read your change before it happens (pull requests).
- **History** — git shows who changed what, when and why.
- **Undo-able** — `terraform destroy` removes everything it made.

## The big idea: you say WHAT, Terraform figures out HOW

This is the single most important idea. There are two ways to give instructions:

| Style | Example | Who does the thinking |
|---|---|---|
| **Step by step** (imperative) | "Create 2 servers. Then if there are 3, delete one." | You |
| **Describe the result** (declarative) | "I want 2 servers." | Terraform |

Terraform is **declarative**. You describe the end result. Terraform looks at
what exists right now, compares it to what you asked for, and works out the steps:

```
You want:      2 servers
Exists now:    3 servers
Terraform:     "I'll delete 1."

You want:      2 servers
Exists now:    2 servers
Terraform:     "Nothing to do."   <- running it twice is safe
```

It's like a thermostat: you set 22°C, and it decides whether to heat or cool.

## How Terraform works — the 3-step loop

```
  your .tf files          what Terraform           the real world
  (what you WANT)   -->   remembers (STATE)  -->   (what EXISTS)
         \___________________________________________/
                      terraform plan  = compare & show the difference
                      terraform apply = make the difference happen
```

1. **Write** — describe what you want in `.tf` files.
2. **Plan** — Terraform shows exactly what it *would* change. Nothing happens yet.
3. **Apply** — you say "yes", and Terraform makes the changes.

## What can Terraform manage?

Almost anything with an API (a way for programs to control it):
- Cloud: AWS, Google Cloud, Azure, DigitalOcean
- Containers: Docker, Kubernetes, Helm
- Services: GitHub repos, Cloudflare DNS, Datadog dashboards, Grafana
- Your own laptop: files, random passwords (used in these notes)

It does this through **providers** — plugins that translate Terraform into each
service's language. More in chapter 04.

## Terraform vs other tools (one line each)

- **Ansible / Chef**: mainly set up *software inside* servers. Terraform mainly *creates* the servers and cloud pieces.
- **CloudFormation / CDK**: AWS-only. Terraform works with many clouds and services.
- **Pulumi**: same idea as Terraform, but written in normal programming languages.
- **OpenTofu**: a free, open-source copy of Terraform made after Terraform changed its licence in 2023. Commands and code are nearly identical (`tofu` instead of `terraform`).

## Remember

- Terraform = describe your infrastructure in code, and let Terraform build it.
- You say **what** you want; Terraform works out **how**.
- Always: **write → plan → apply**.
