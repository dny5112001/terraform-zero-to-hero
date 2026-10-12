output "name_prefix" {
  value = local.name_prefix
}

output "files" {
  value = local_file.server[*].filename
}

output "summary" {
  description = "Try: terraform output -raw summary"
  value       = "${var.instance_count} server(s) in ${var.environment}"
}
