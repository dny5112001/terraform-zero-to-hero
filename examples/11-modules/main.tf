module "alice" {
  source = "./modules/greeting-file"
  name   = "alice"
}

module "bob" {
  source   = "./modules/greeting-file"
  name     = "bob"
  greeting = "Namaste"
}

# The same module, many times, with for_each.
module "team" {
  for_each = toset(["dev", "ops"])
  source   = "./modules/greeting-file"
  name     = each.key
  greeting = "Hi team"
}

output "files" {
  value = concat(
    [module.alice.path, module.bob.path],
    [for m in module.team : m.path],
  )
}
