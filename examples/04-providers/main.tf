# Two providers working together: "random" makes a name, "local" writes a file.
# After `terraform init`, look in .terraform/providers/ and .terraform.lock.hcl.

resource "random_pet" "server" {
  length = 2
}

resource "local_file" "server_name" {
  filename = "${path.module}/server-name.txt"
  content  = "Our new server is called ${random_pet.server.id}\n"
}
