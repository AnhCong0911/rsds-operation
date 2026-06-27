# eks module — extend with provider-specific resources
variable "name" { type = string }
variable "tags" { type = map(string); default = {} }

output "module_name" {
  value = var.name
}
