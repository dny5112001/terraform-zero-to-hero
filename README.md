# Terraform: Zero to Hero

Plain-English notes for learning Terraform from nothing to "I can run this at work".
No jargon without an explanation. Every chapter has small examples you can run
on your laptop — **no cloud account, no bill**.

## How to use these notes

1. Read a chapter (10–20 minutes each).
2. Run its example in `examples/` — typing it yourself beats reading it.
3. Do the "Try it" bits at the end of each chapter.
4. When you finish chapter 12, go build the bigger project:
   [k8s-terraform-lab](https://github.com/dny5112001/k8s-terraform-lab) (Kubernetes + fake AWS, all local).

## Chapters

### Part 1 — Zero: the basics
| # | Chapter | You'll learn |
|---|---|---|
| 01 | [What is Terraform?](notes/01-what-is-terraform.md) | The problem it solves, in one picture |
| 02 | [Install and first run](notes/02-install-and-first-run.md) | `init`, `plan`, `apply`, `destroy` |
| 03 | [Reading and writing the language](notes/03-the-language.md) | Blocks, values, types, comments |
| 04 | [Providers](notes/04-providers.md) | The "translators" that talk to AWS, Docker, etc. |
| 05 | [Resources and how they connect](notes/05-resources-and-dependencies.md) | Creating things, and the order they're built in |

### Part 2 — Getting comfortable
| # | Chapter | You'll learn |
|---|---|---|
| 06 | [Variables, outputs and locals](notes/06-variables-outputs-locals.md) | Inputs, results and shortcuts |
| 07 | [State — Terraform's memory](notes/07-state.md) | The most important idea in Terraform |
| 08 | [Reading a plan like a pro](notes/08-reading-plans-and-lifecycle.md) | `+ ~ - -/+`, and protecting things from deletion |
| 09 | [Data sources](notes/09-data-sources.md) | Looking things up instead of creating them |
| 10 | [Loops, conditions and functions](notes/10-loops-conditions-functions.md) | `count`, `for_each`, `for`, `? :`, built-in helpers |

### Part 3 — Hero: real-world Terraform
| # | Chapter | You'll learn |
|---|---|---|
| 11 | [Modules](notes/11-modules.md) | Reusable building blocks |
| 12 | [Organising a real project](notes/12-organising-projects.md) | Environments, folders, splitting state |
| 13 | [Changing things safely](notes/13-import-move-remove.md) | `import`, `moved`, `removed` |
| 14 | [Working in a team](notes/14-team-workflow.md) | Remote state, locking, CI, secrets |
| 15 | [Testing and quality checks](notes/15-testing-and-quality.md) | `validate`, checks, `terraform test`, linters |
| 16 | [Common mistakes and fixes](notes/16-mistakes-and-troubleshooting.md) | What goes wrong and how to get out |
| 17 | [Cheat sheet](notes/17-cheat-sheet.md) | Every command and pattern on one page |
| 18 | [Glossary + interview questions](notes/18-glossary-and-interview.md) | Check yourself |

## Running the examples

You need only Terraform (1.9 or newer). Each example folder works the same way:

```bash
cd examples/02-first-run
terraform init
terraform plan
terraform apply
terraform destroy
```

The examples use "local" providers (they create files on your computer, random
names, etc.), so they are safe and free. The ideas are exactly the same as
creating servers on AWS — only the provider changes.
