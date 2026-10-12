# data = read something that already exists. It never creates or changes it.
data "local_file" "input" {
  filename = "${path.module}/input.txt"
}

locals {
  lines = compact(split("\n", data.local_file.input.content)) # drop empty lines
}

resource "local_file" "report" {
  filename = "${path.module}/report.txt"
  content  = "input.txt has ${length(local.lines)} lines. First: \"${local.lines[0]}\"\n"
}
