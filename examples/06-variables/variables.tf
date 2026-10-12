variable "project" {
  description = "Project name, used in every name"
  type        = string
  default     = "notes"
}

variable "environment" {
  description = "dev, staging or prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging or prod."
  }
}

variable "instance_count" {
  description = "How many 'servers' (files) to make"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 5
    error_message = "Pick between 1 and 5 instances."
  }
}

variable "tags" {
  type    = map(string)
  default = { team = "web" }
}
