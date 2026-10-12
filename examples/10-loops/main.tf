variable "enable_debug" {
  type    = bool
  default = false
}

# --- count: copies identified by NUMBER ------------------------------------
locals {
  names_list = ["alice", "bob", "carol"]
}

resource "local_file" "by_count" {
  count    = length(local.names_list)
  filename = "${path.module}/out/count-${local.names_list[count.index]}.txt"
  content  = "I am ${local.names_list[count.index]} at position ${count.index}\n"
}

# --- for_each: copies identified by NAME (prefer this) ---------------------
resource "local_file" "by_name" {
  for_each = toset(["alice", "bob", "carol"])
  filename = "${path.module}/out/foreach-${each.key}.txt"
  content  = "I am ${each.key}\n"
}

# --- map with for_each: key + value ----------------------------------------
resource "local_file" "retention" {
  for_each = {
    logs   = "30 days"
    photos = "forever"
  }
  filename = "${path.module}/out/retention-${each.key}.txt"
  content  = "${each.key} are kept for ${each.value}\n"
}

# --- on/off switch ----------------------------------------------------------
resource "local_file" "debug" {
  count    = var.enable_debug ? 1 : 0
  filename = "${path.module}/out/debug.txt"
  content  = "debug mode on\n"
}

# --- for expressions ---------------------------------------------------------
locals {
  upper_names  = [for n in local.names_list : upper(n)]
  name_lengths = { for n in local.names_list : n => length(n) }
  long_names   = [for n in local.names_list : n if length(n) > 3]
}

output "count_files" {
  value = local_file.by_count[*].filename # splat works with count
}

output "foreach_files" {
  value = [for f in local_file.by_name : f.filename]
}

output "debug_file" {
  value = one(local_file.debug[*].filename) # null when switched off
}

output "expressions" {
  value = {
    upper  = local.upper_names
    length = local.name_lengths
    long   = local.long_names
  }
}
