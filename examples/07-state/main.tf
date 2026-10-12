# Apply, then open terraform.tfstate: the password is there in plain text,
# even though the output is marked sensitive. That's why state is secret.

resource "random_password" "db" {
  length = 20
}

resource "local_file" "managed" {
  filename = "${path.module}/managed.txt"
  content  = "Terraform owns this file. Edit it by hand, then run terraform plan.\n"
}

output "db_password" {
  value     = random_password.db.result
  sensitive = true
}
