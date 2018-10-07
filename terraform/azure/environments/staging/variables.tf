variable "resource_group_name" {}
variable "container_name" {}
variable "storage_account" {}
variable "location"{}
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "azure_location" {}

variable "os_disk_vhd_uri" {}
variable "os_disk_wfe_vhd_uri" {}

variable "instance_types_by_role" {
  type = "map"
  default = {
    "DomainController" = "t2.micro"
    "Database"         = "m4.large"
    "AppServer"        = "t2.micro"
    "WFE"              = "t2.micro"
  }
}
variable "domain_Name" {
  default="sposcar.local"
}

# should grab from Vault or some other secure place
variable "domain_admin_password" {
default = "Pass@word1!" 
}

variable "private_ip_addresses" {
  type    = "map"
    default = {
      "DomainController" = "10.10.1.50"
      "Database" = "10.10.1.51"
      "AppServer" = "10.10.1.52"
      "WFE" = "10.10.1.53"
    }
}

variable "ami_by_sp_role" {
  type = "map"
  default = {
    "DomainController" = "ami-dc92a8bc"
    "Database"         = "ami-fc8fb49c"
    "AppServer"        = "ami-dc92a8bc"
    "WFE"              = "ami-dc92a8bc"
  }
}
