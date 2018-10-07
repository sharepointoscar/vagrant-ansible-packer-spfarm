
variable "region" {
  description = "The AWS region to create resources in."
  default = "us-west-1"
}

variable "ami" {
  description = "The custom Windows 2016 AMI to spawn"
  default = {
    us-west-1 = "ami-c52a26a5"
  }
}

variable "instance_types_by_role" {
  type = "map"
  default = {
    "DomainController" = "t2.small"
    "Database"         = "m4.large"
    "AppServer"        = "t2.medium"
    "WFE"              = "t2.medium"
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
      "DomainController"  = "10.10.1.50"
      "Database"          = "10.10.1.51"
      "AppServer"         = "10.10.1.52"
      "WFE"               = "10.10.2.53"
    }
}

variable "ami_by_sp_role" {
  type = "map"
  default = {
    "DomainController" = "ami-c52a26a5"
    "Database"         = "ami-fc8fb49c"
    "AppServer"        = "ami-c52a26a5"
    "WFE"              = "ami-c52a26a5"
  }
}