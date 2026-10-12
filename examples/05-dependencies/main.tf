# Nothing here says "do this first". Terraform works out the order from references:
#   random_password.db  ->  local_file.config  ->  local_file.readme

resource "random_password" "db" {
  length  = 16
  special = false
}

resource "local_file" "config" {
  filename = "${path.module}/app.conf"
  content  = "db_password=${random_password.db.result}\n" # reference #1
}

resource "local_file" "readme" {
  filename = "${path.module}/README.generated.txt"
  content  = "The config lives in ${local_file.config.filename}\n" # reference #2
}

# This one depends on nothing, so Terraform creates it at the same time as the password.
resource "random_pet" "unrelated" {}
