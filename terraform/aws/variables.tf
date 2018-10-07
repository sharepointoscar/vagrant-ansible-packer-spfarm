
variable "region" {
  description = "The AWS region to create resources in."
  default = "us-west-1"
}

variable "availability_zone" {
  description = "The availability zone"
  default = "us-west-1c"
}

variable "sprole_name" {
  description = "The name of the SharePoint server Role"
  default = "WFE1"
}
variable "amis" {
  description = "The custom Windows 2016 AMI to spawn"
  default = {
    us-west-1 = "ami-955c6ef5"
  }
}

variable "instance_type" {
  default = "t2.micro"
}

