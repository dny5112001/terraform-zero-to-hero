# 16 · Common mistakes and how to fix them

## Mistakes that cost people the most

| Mistake | What happens | Prevention |
|---|---|---|
| Typing `yes` without reading the plan | A database gets replaced; data gone | Read the summary line; look for `-/+` and `destroy` |
| Committing `terraform.tfstate` | Secrets leaked in git | `.gitignore`; remote backend |
| Renaming a resource in code | Destroy + recreate | `moved` block |
| Using `count` for a list of named things | Removing one item reshuffles and replaces others | `for_each` |
| Changing things by hand in the console | Drift; next apply undoes it | Change only through Terraform |
| Not pinning provider versions | A new major version breaks your code one morning | `~>` + committed lock file |
| One giant state for everything | Slow plans, huge blast radius | Split by layer and environment |
| `-target` as a habit | Code and reality slowly drift apart | Use only in emergencies |
| No `prevent_destroy` on precious data | One bad PR deletes it | Add it to databases and important buckets |

## Reading errors

Terraform errors are usually clear. They tell you the **file and line**:

```
Error: Missing required argument

  on main.tf line 12, in resource "local_file" "hello":
  12: resource "local_file" "hello" {

The argument "filename" is required, but no definition was found.
```

Read the last sentence first, then go to the file and line.

## Common errors and fixes

**`Error: Inconsistent dependency lock file`** / **provider not installed**
→ You added or changed a provider. Run `terraform init` (or `init -upgrade`).

**`Error: Module not installed`**
→ You added a module. Run `terraform init`.

**`Error acquiring the state lock`**
→ Someone else (or your crashed run) is applying. Wait. If you're *sure* it's
stale: `terraform force-unlock <ID>`.

**`Error: ... already exists`** (e.g. BucketAlreadyExists)
→ The real thing exists but isn't in your state. Either `import` it (ch. 13),
or pick a different name. (Bucket names are global across all AWS accounts!)

**`Error: Invalid count argument` / `Invalid for_each argument ... known only after apply`**
→ `count`/`for_each` must be known at plan time. Don't base them on IDs that only
exist after creation. Use input variables or static keys instead.

**`Error: Cycle: a, b`**
→ A needs B and B needs A. Break the loop — often by splitting a resource into
two (e.g. a security group plus separate rule resources).

**Plan wants to change something every time** ("perpetual diff")
→ The provider stores the value differently from how you wrote it (e.g. JSON
spacing, upper/lower case). Write it the way the provider returns it, use
`jsonencode()`, or as a last resort `ignore_changes`.

**`Error: Unsupported attribute`**
→ Typo or wrong attribute name. Check the docs' attribute list, or use
`terraform console` to inspect the object.

**Apply failed halfway**
→ Don't panic. Whatever succeeded is saved in state. Fix the cause and run
`apply` again — Terraform continues from where it got to.

**State says something exists, but it was deleted by hand**
→ `terraform plan` will notice it's gone and offer to recreate it. If you don't
want it any more, remove it from code too.

## Turn on detailed logs

```bash
TF_LOG=DEBUG terraform plan 2> debug.log
```

Levels: `ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE`. The log shows every API call
the provider makes — great for "why is AWS saying no?". (Logs may contain secrets — don't share them blindly.)

## A calm recovery checklist

1. **Stop.** Don't run more commands hoping it fixes itself.
2. **Back up the state:** `terraform state pull > backup-$(date +%s).tfstate`.
3. **Look:** `terraform plan`, `terraform state list`, the cloud console.
4. **Fix the smallest thing possible** (import, moved, removed, a code change).
5. **Plan again until it shows exactly what you expect.** Then apply.

## Remember

- Most disasters are "didn't read the plan" or "renamed without `moved`".
- Errors give a file and line — read the last sentence first.
- Back up state before any surgery.
