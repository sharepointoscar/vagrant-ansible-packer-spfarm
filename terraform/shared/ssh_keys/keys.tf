variable "key_name" {
    default = "spfarm_rsa"
}

variable "pub_key_path" {}
variable "priv_key_path" {}

output "name" {
    value = "${var.key_name}"
}
output "path" {
  value = "${path.module}"
}

output "public_key_path" {
  value = "${path.module}/ssh_keys/${module.key_name.name}.pub"
}
  
output "private_key_path" {
  value = "${path.module}/ssh_keys/${module.key_name.name}.pem"
}