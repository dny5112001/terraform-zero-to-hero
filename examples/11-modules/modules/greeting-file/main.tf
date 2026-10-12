# A child module declares the providers it needs, but never configures them.
terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
  }
}

resource "local_file" "this" {
  filename = "${path.root}/out/${var.name}.txt"
  content  = "${var.greeting}, ${var.name}!"
}
