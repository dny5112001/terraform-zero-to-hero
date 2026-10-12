variable "name" {
  description = "Who to greet"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "name must not be empty."
  }
}

variable "greeting" {
  description = "The greeting word"
  type        = string
  default     = "Hello"
}
