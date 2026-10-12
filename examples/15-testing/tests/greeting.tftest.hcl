variables {
  name = "alice"
}

run "default_greeting" {
  command = plan # just plan, create nothing

  assert {
    condition     = local_file.this.content == "Hello, alice!"
    error_message = "Wrong greeting text."
  }
}

run "custom_greeting" {
  command = apply # really create, then clean up after the test

  variables {
    greeting = "Namaste"
  }

  assert {
    condition     = fileexists(output.path)
    error_message = "The file was not created."
  }
}

run "rejects_empty_name" {
  command = plan

  variables {
    name = ""
  }

  expect_failures = [var.name] # we WANT validation to fail here
}
