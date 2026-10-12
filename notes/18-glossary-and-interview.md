# 18 · Glossary + interview questions

## Glossary (plain English)

| Word | Meaning |
|---|---|
| **Infrastructure as Code (IaC)** | Describing servers, networks, databases etc. in code files instead of clicking |
| **Declarative** | You describe the end result; the tool works out the steps |
| **HCL** | The language Terraform files are written in |
| **Provider** | A plugin that lets Terraform talk to one service (AWS, GitHub...) |
| **Resource** | One thing Terraform creates and manages |
| **Data source** | A read-only lookup of something that already exists |
| **Address** | A resource's full name in Terraform, e.g. `module.app.aws_s3_bucket.logs` |
| **Argument** | A setting you write inside a block |
| **Attribute** | A value you can read from a resource (often only known after creation) |
| **Variable** | An input to your code |
| **Output** | A result your code shows or passes on |
| **Local** | A named shortcut for a value used inside the code |
| **Module** | A folder of Terraform code, used like a reusable function |
| **Root module** | The folder you run Terraform in |
| **State** | Terraform's memory: what it created and how it maps to your code |
| **Backend** | Where state is stored (local file, S3, HCP Terraform...) |
| **Locking** | Stops two people changing the same state at once |
| **Drift** | The real world no longer matches your code (someone changed it by hand) |
| **Plan** | A preview of what Terraform will change |
| **Apply** | Actually making the changes |
| **Refresh** | Asking the provider what really exists now |
| **Replace** | Destroying and recreating a resource because a setting can't change in place |
| **Blast radius** | How much can break from one mistake |
| **Lock file** | `.terraform.lock.hcl` — the exact provider versions to use |
| **Workspace** | Several separate states for one folder |
| **Meta-argument** | A setting every resource has: `count`, `for_each`, `depends_on`, `provider`, `lifecycle` |
| **Idempotent** | Running it again with no changes does nothing |

## Interview questions (with short answers)

**1. What is Terraform and why use it?**
An Infrastructure as Code tool. You describe infrastructure in files; it creates
and updates it. Benefits: repeatable, reviewable in PRs, version history, works
with many clouds/services.

**2. What does `terraform init` do?**
Downloads providers and modules, sets up the backend, writes the lock file.

**3. Explain plan vs apply.**
Plan compares code, state and reality and shows the changes without doing them.
Apply does them.

**4. What is state and why is it needed?**
A record linking resources in code to real objects. Needed to know what
Terraform owns, what to update or delete, and to track IDs.

**5. Why use remote state?**
Sharing between team members, locking against simultaneous changes, durability,
and access control/encryption for the secrets inside it.

**6. What is drift and how do you detect it?**
Changes made outside Terraform. `terraform plan` (or `plan -refresh-only`) shows it.

**7. `count` vs `for_each`?**
`count` makes N copies identified by number; removing one in the middle shifts
the rest and causes replacements. `for_each` identifies copies by key, so
changes only affect that key.

**8. How do you rename a resource without destroying it?**
A `moved` block (or `terraform state mv`).

**9. How do you bring an existing resource under Terraform?**
An `import` block (optionally with `-generate-config-out`) or `terraform import`.

**10. How do you stop a resource from being deleted?**
`lifecycle { prevent_destroy = true }`.

**11. What does `create_before_destroy` do?**
When replacing, creates the new resource first, then destroys the old one, reducing downtime.

**12. How do you manage multiple environments?**
Usually a folder per environment sharing modules, each with its own state and
backend key. Workspaces for short-lived copies.

**13. How do you handle secrets?**
Never in code or committed tfvars. Use a secret manager, environment variables,
`sensitive`, provider-managed secrets, and ephemeral/write-only values where
supported. Protect state, because it can contain them.

**14. What is a module? How do you version it?**
A reusable folder with inputs, resources, outputs. Version with git tags or
registry versions and pin `version`/`?ref=` when calling it.

**15. What is `depends_on` and when do you use it?**
Forces an order when there's no reference between resources. Use rarely.

**16. What does `terraform validate` not catch?**
Anything that needs the real service — e.g. invalid instance types, permission
problems, name clashes. Linters and plan/apply catch those.

**17. An apply failed halfway. What now?**
State has what succeeded. Fix the cause, re-run plan and apply; Terraform continues.

**18. What is the state lock error and how do you handle it?**
Another run holds the lock. Wait; only `force-unlock` if sure the lock is stale.

**19. How would you set up Terraform in CI/CD?**
On PR: fmt check, validate, lint, security scan, plan posted for review. On
merge: apply the reviewed plan with approval, using short-lived OIDC credentials.

**20. Terraform vs Ansible?**
Terraform provisions infrastructure declaratively and tracks state. Ansible
mainly configures software on existing machines (procedural, no state file).
They're often used together.

## Where to go next

1. Build the [k8s-terraform-lab](https://github.com/dny5112001/k8s-terraform-lab) and do its exercises.
2. Read the official tutorials: [developer.hashicorp.com/terraform/tutorials](https://developer.hashicorp.com/terraform/tutorials).
3. Read the code of a popular module, e.g. `terraform-aws-modules/vpc/aws`.
4. Optional certification: **HashiCorp Certified: Terraform Associate**.
