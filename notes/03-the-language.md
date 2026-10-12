# 03 · Reading and writing the language (HCL)

Terraform code is written in **HCL** (HashiCorp Configuration Language). It's
designed to be easy to read — closer to a settings file than a programming language.

## Blocks: the building pieces

Everything is a **block**. A block has a type, sometimes labels, and a body in `{ }`:

```hcl
resource "local_file" "hello" {     # block type: resource
  filename = "hello.txt"            #   labels: "local_file" and "hello"
  content  = "hi"                   #   body: settings inside { }
}
```

Read it as: *"a resource, of type local_file, that I'll call hello."*

The block types you'll meet:

| Block | What it's for | Chapter |
|---|---|---|
| `terraform { }` | settings for Terraform itself (versions, where to keep state) | 04, 14 |
| `provider "aws" { }` | settings for a provider (region, login) | 04 |
| `resource "type" "name" { }` | something to **create and manage** | 05 |
| `data "type" "name" { }` | something to **look up** (not create) | 09 |
| `variable "name" { }` | an input | 06 |
| `output "name" { }` | a result to show/share | 06 |
| `locals { }` | named shortcuts | 06 |
| `module "name" { }` | use a reusable package of Terraform code | 11 |

## Arguments: `name = value`

Inside a block you set **arguments**:

```hcl
filename = "hello.txt"
```

Some settings are nested blocks instead of `=`:

```hcl
resource "aws_instance" "web" {
  ami           = "ami-123"
  instance_type = "t3.micro"

  root_block_device {        # a nested block — no "=" sign
    volume_size = 20
  }
}
```

How do you know which settings exist? The **provider's docs** on
[registry.terraform.io](https://registry.terraform.io). Every resource page lists
its arguments, which are required, and what it gives back ("attributes").

## Types of values

| Type | Example | Like... |
|---|---|---|
| string | `"hello"` | text |
| number | `3`, `0.5` | numbers |
| bool | `true`, `false` | yes/no |
| list | `["a", "b", "c"]` | an ordered row of things |
| map | `{ env = "dev", team = "web" }` | a lookup table: name → value |
| object | `{ name = "x", size = 2 }` | a map where each key can have a different type |
| set | `toset(["a", "b"])` | a list with no order and no duplicates |
| null | `null` | "not set" — Terraform uses the default |

## Putting values inside text

Use `${ }` inside a string:

```hcl
content = "Hello, ${var.name}! You have ${length(var.items)} items."
```

Multi-line text uses `<<-EOT ... EOT` ("heredoc"):

```hcl
content = <<-EOT
  Line one
  Line two
EOT
```

## Comments

```hcl
# A comment (most common)
// Also a comment
/* A comment
   over many lines */
```

## Referring to other things

You connect things by **referencing** them: `<type>.<name>.<attribute>`

```hcl
resource "random_pet" "name" {}

resource "local_file" "greeting" {
  filename = "greeting.txt"
  content  = "Hi, ${random_pet.name.id}"   # use the pet name created above
}
```

| Write this | To get |
|---|---|
| `random_pet.name.id` | an attribute of a resource |
| `var.region` | a variable |
| `local.tags` | a local value |
| `data.aws_ami.ubuntu.id` | a looked-up value |
| `module.network.vpc_id` | an output of a module |
| `path.module` | the folder this file is in |

## File layout (a convention, not a rule)

Terraform merges all `.tf` files in a folder, so names are just for humans.
Most projects use:

```
main.tf          # the resources
variables.tf     # inputs
outputs.tf       # results
providers.tf     # provider + terraform blocks (sometimes inside main.tf)
terraform.tfvars # values for the variables
```

## Try it

Open [`examples/03-language/main.tf`](../examples/03-language/main.tf). It uses
every value type and writes them into a file. Run it, then open `out.txt` and
match each line to the code.

## Remember

- Everything is a **block**; inside blocks you set **arguments**.
- Connect things with **references** like `random_pet.name.id`.
- The provider docs on the Terraform Registry tell you every setting.
