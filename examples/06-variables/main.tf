locals {
  name_prefix = "${var.project}-${var.environment}" # e.g. notes-dev
  all_tags    = merge(var.tags, { environment = var.environment })
}

resource "local_file" "server" {
  count    = var.instance_count
  filename = "${path.module}/out/${local.name_prefix}-server-${count.index}.txt"
  content  = "tags: ${jsonencode(local.all_tags)}\n"
}
