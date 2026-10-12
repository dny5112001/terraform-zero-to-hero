variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_count" {
  type    = number
  default = 1
}

resource "local_file" "important" {
  filename = "${path.module}/important.txt"
  content  = "Pretend this is a production database.\n"

  lifecycle {
    prevent_destroy = true # `terraform destroy` will refuse while this is here
  }
}

resource "local_file" "servers" {
  count    = var.instance_count
  filename = "${path.module}/server-${count.index}.txt"
  content  = "server ${count.index} in ${var.environment}\n"

  lifecycle {
    precondition {
      condition     = var.environment != "prod" || var.instance_count >= 2
      error_message = "Production needs at least 2 instances."
    }
  }
}
