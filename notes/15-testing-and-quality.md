# 15 · Testing and quality checks

From quick and cheap (run constantly) to slower and thorough:

```
fmt → validate → lint → security scan → variable validation & checks → terraform test → plan review
```

## 1. `terraform fmt` — tidy formatting

```bash
terraform fmt -recursive          # fix formatting everywhere
terraform fmt -check -recursive   # fail (in CI) if anything isn't formatted
```

## 2. `terraform validate` — is the code correct?

Checks for typos, missing required settings, wrong types — without touching any
real infrastructure. Needs `terraform init` first (`init -backend=false` is fine in CI).

## 3. Linters — catch mistakes validate can't

**TFLint** knows provider rules: "t3.mirco isn't a real instance type",
"this variable is declared but never used".

```bash
brew install tflint
tflint --init && tflint
```

## 4. Security scanners — catch risky settings

**Checkov** or **Trivy** flag things like public buckets, open firewall ports,
missing encryption:

```bash
pip install checkov && checkov -d .
trivy config .
```

You can mark accepted exceptions in code with a comment and a reason.

## 5. Checks inside your code

You've seen these already — they run on every plan:

```hcl
variable "environment" {
  type = string
  validation {                                        # check an input
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

resource "aws_instance" "web" {
  # ...
  lifecycle {
    postcondition {                                   # check a result
      condition     = self.public_ip == ""
      error_message = "Web servers must not get a public IP."
    }
  }
}
```

### `check` blocks — health checks that warn, not fail

```hcl
check "website_is_up" {
  data "http" "site" {
    url = "https://example.com"
  }

  assert {
    condition     = data.http.site.status_code == 200
    error_message = "The website did not return 200."
  }
}
```

If it fails you get a **warning**, but the apply still goes ahead. Good for "is
everything still healthy?" checks.

## 6. `terraform test` — automated tests for modules

Write test files ending in `.tftest.hcl` in a `tests/` folder:

```hcl
# tests/greeting.tftest.hcl
variables {
  name = "alice"
}

run "default_greeting" {
  command = plan                       # just plan, create nothing

  assert {
    condition     = local_file.this.content == "Hello, alice!"
    error_message = "Wrong greeting text."
  }
}

run "custom_greeting" {
  command = apply                      # really create, then auto-destroy after the test

  variables {
    greeting = "Namaste"
  }

  assert {
    condition     = output.path != ""
    error_message = "Output path is empty."
  }
}

run "rejects_empty_name" {
  command = plan
  variables {
    name = ""
  }
  expect_failures = [var.name]         # we WANT the validation to fail here
}
```

```bash
terraform test
```

Tests can also replace real providers with **mocks** (`mock_provider "aws" {}`),
so you can test AWS modules without an AWS account.

## 7. Plan review

The final and most important "test" is a human reading the plan (chapter 08).

## Try it

[`examples/15-testing`](../examples/15-testing/) has a module with validation and a
test file. Run `terraform init` then `terraform test`. Then break the module
(change the greeting text) and watch the test fail.

## Remember

- In CI, every PR: `fmt -check`, `validate`, a linter, a security scan, `plan`.
- Put validation and conditions in the code itself.
- Use `terraform test` for modules others depend on.
