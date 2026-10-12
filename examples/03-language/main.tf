# Every value type from chapter 03, written into one file.
locals {
  a_string = "hello"
  a_number = 42
  a_bool   = true
  a_list   = ["red", "green", "blue"]
  a_map    = { env = "dev", team = "web" }
  an_object = {
    name = "server-1"
    size = 2
  }
}

resource "random_pet" "name" {}

resource "local_file" "out" {
  filename = "${path.module}/out.txt"

  # A heredoc: multi-line text. ${ } puts values inside text.
  content = <<-EOT
    string : ${local.a_string}
    number : ${local.a_number}
    bool   : ${local.a_bool}
    list   : ${join(", ", local.a_list)} (first is ${local.a_list[0]})
    map    : env=${local.a_map["env"]}, team=${local.a_map.team}
    object : ${local.an_object.name} has size ${local.an_object.size}
    pet    : ${random_pet.name.id}   <- a reference to another resource
  EOT
}
