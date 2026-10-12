# 10 · Loops, conditions and functions

## Making many copies: `count`

```hcl
resource "local_file" "server" {
  count    = 3
  filename = "server-${count.index}.txt"   # count.index = 0, 1, 2
  content  = "I am server number ${count.index}"
}
```

Addresses become `local_file.server[0]`, `[1]`, `[2]`.

### The `count` trap

```hcl
variable "names" { default = ["alice", "bob", "carol"] }

resource "local_file" "user" {
  count    = length(var.names)
  filename = "${var.names[count.index]}.txt"
}
```

Remove `"alice"` from the list. Now `bob` moves from `[1]` to `[0]`, and
`carol` from `[2]` to `[1]`. Terraform sees *changed* items at each position
and **replaces bob and carol**, not just deletes alice. With real servers,
that's a disaster.

## Better: `for_each` — copies identified by a name

```hcl
resource "local_file" "user" {
  for_each = toset(["alice", "bob", "carol"])
  filename = "${each.key}.txt"
  content  = "Hello ${each.value}"
}
```

Addresses are `local_file.user["alice"]`, `["bob"]`... Remove alice, and
**only alice is deleted**. Nothing else moves.

With a map, you get a key and a value:

```hcl
variable "buckets" {
  default = {
    logs   = "30 days"
    photos = "forever"
  }
}

resource "local_file" "bucket" {
  for_each = var.buckets
  filename = "${each.key}.txt"    # logs, photos
  content  = each.value           # "30 days", "forever"
}
```

**Rule of thumb:**
- `count` → "N identical things", or an on/off switch (below).
- `for_each` → a set of *different* named things. **Use this most of the time.**

## Conditions: `condition ? if_true : if_false`

```hcl
instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"
```

### On/off switch for a resource

```hcl
resource "local_file" "debug_log" {
  count    = var.enable_debug ? 1 : 0     # 1 = create it, 0 = don't
  filename = "debug.txt"
  content  = "debug on"
}
```

Refer to it as `local_file.debug_log[0]` — and only when it exists, e.g.
`one(local_file.debug_log[*].filename)` returns the value or `null`.

## `for` expressions — transform lists and maps

Like a loop that builds a new list or map:

```hcl
locals {
  names        = ["alice", "bob"]
  upper_names  = [for n in local.names : upper(n)]          # ["ALICE", "BOB"]
  name_lengths = { for n in local.names : n => length(n) }  # { alice = 5, bob = 3 }
  long_names   = [for n in local.names : n if length(n) > 3] # ["alice"]
}
```

`[ ]` makes a list, `{ }` makes a map, `if` filters.

### Splat `[*]` — grab one attribute from all copies

```hcl
output "all_files" {
  value = local_file.server[*].filename      # works with count
}

output "user_files" {
  value = [for f in local_file.user : f.filename]   # use "for" with for_each
}
```

## `dynamic` blocks — repeat a nested block

When a resource has repeatable nested blocks (like firewall rules):

```hcl
variable "ports" { default = [80, 443] }

resource "aws_security_group" "web" {
  name = "web"

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

Handy, but don't overuse it — plain blocks are easier to read.

## Built-in functions (the ones you'll actually use)

You can't write your own functions, but there are lots built in.
Test them live with `terraform console`:

```bash
$ terraform console
> upper("hello")
"HELLO"
> length(["a", "b"])
2
```

| Group | Functions |
|---|---|
| Text | `upper`, `lower`, `replace`, `split`, `join`, `format`, `trimspace`, `substr` |
| Lists | `length`, `concat`, `contains`, `distinct`, `flatten`, `sort`, `element`, `slice` |
| Maps | `keys`, `values`, `merge`, `lookup`, `zipmap` |
| Type changes | `tostring`, `tonumber`, `toset`, `tolist`, `tomap` |
| Encoding | `jsonencode`, `jsondecode`, `yamlencode`, `yamldecode`, `base64encode` |
| Files | `file`, `templatefile`, `fileexists`, `abspath` |
| Safety | `try` (use a fallback if something errors), `can` (true/false: would it work?), `coalesce` (first non-empty) |
| Networks | `cidrsubnet` (split an IP range into smaller ones) |
| Hashing | `sha256`, `md5`, `filesha256` |

`templatefile` is great for config files:

```hcl
content = templatefile("${path.module}/config.tpl", { port = 8080, env = var.environment })
```

## Try it

[`examples/10-loops`](../examples/10-loops/main.tf):
1. Apply. Look at `terraform state list` — note `[0]` vs `["alice"]` style addresses.
2. Remove `"alice"` from **both** lists in `main.tf`, then plan. Compare: `count` replaces things, `for_each` deletes only alice.
3. Plan with `-var enable_debug=true` to switch the optional file on.
4. Play in `terraform console` with the functions above.

## Remember

- Prefer `for_each` over `count` for named things.
- `? :` for choices, `count = x ? 1 : 0` for on/off.
- `terraform console` is your playground for expressions.
