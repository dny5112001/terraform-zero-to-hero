# A tiny module with a test suite in tests/. Run: terraform init && terraform test
terraform {
  required_version = ">= 1.9"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "name" {
  type = string

  validation {
    condition     = length(var.name) > 0
    error_message = "name must not be empty."
  }
}

variable "greeting" {
  type    = string
  default = "Hello"
}

resource "local_file" "this" {
  filename = "${path.module}/out/${var.name}.txt"
  content  = "${var.greeting}, ${var.name}!"
}

output "path" {
  value = local_file.this.filename
}
