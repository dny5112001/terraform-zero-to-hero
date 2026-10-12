# Step 1: apply this as-is. Then follow README.md.
resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content  = "hello\n"
}
