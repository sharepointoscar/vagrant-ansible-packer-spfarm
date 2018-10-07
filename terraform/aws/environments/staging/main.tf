module "vpc_spfarm_staging" {
  source           = "github.com/SharePointOscar/terraform_modules.git//aws_modules//vpc?ref=v0.0.1"
  vpc_name         = "vpc_spfarm_staging"
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  dns_support      = true
  dns_hostnames    = true
  enable_classiclink = false
}

resource "aws_internet_gateway" "internet_gateway"  {
  vpc_id   = "${module.vpc_spfarm_staging.id}"

}

module "route_table_public_sub" {
  source = "github.com/SharePointOscar/terraform_modules.git//aws_modules//route_table"
  vpc_id = "${module.vpc_spfarm_staging.id}"
}

module "route" {
  source                  = "github.com/SharePointOscar/terraform_modules.git//aws_modules//route"
  route_table_id          = "${module.route_table_public_sub.route_table_id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.internet_gateway.id}"        
}

module "route_table_association_public_sub_a" {
  source         = "github.com/SharePointOscar/terraform_modules.git//aws_modules//route_table_association"
  subnet_id      = "${module.subnet-public-a.id}"
  route_table_id = "${module.route_table_public_sub.route_table_id}"
}

module "route_table_association_public_sub_b" {
  source         = "github.com/SharePointOscar/terraform_modules.git//aws_modules//route_table_association"
  subnet_id      = "${module.subnet-public-b.id}"
  route_table_id = "${module.route_table_public_sub.route_table_id}"
}

# private subnet route tables and associations
module "route_table_private_sub" {
  source = "github.com/SharePointOscar/terraform_modules.git//aws_modules//route_table"
  vpc_id = "${module.vpc_spfarm_staging.id}"
}

module "route_priv_sub" {
  source                 = "github.com/SharePointOscar/terraform_modules.git//aws_modules//route"
  route_table_id         = "${module.route_table_public_sub.route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

module "route_table_association_private_sub_a" {
  source         = "github.com/SharePointOscar/terraform_modules.git//aws_modules//route_table_association"
  subnet_id      = "${module.subnet-private-a.id}"
  route_table_id = "${module.route_table_private_sub.route_table_id}"
}

module "route_table_association_private_sub_b" {
  source         = "github.com/SharePointOscar/terraform_modules.git//aws_modules//route_table_association"
  subnet_id      = "${module.subnet-private-b.id}"
  route_table_id = "${module.route_table_private_sub.route_table_id}"
}

# Declare the data source
data "aws_availability_zones" "available" {}

module "subnet-public-a" {
  source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//subnet"
  subnet_name       = "subnet_public_a_spfarm_staging"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id            = "${module.vpc_spfarm_staging.id}"
  cidr_block        = "10.10.1.0/24"
  map_public_ip_on_launch = true
}

module "subnet-public-b" {
  source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//subnet"
  subnet_name       = "subnet_public_b_spfarm_staging"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  vpc_id            = "${module.vpc_spfarm_staging.id}"
  cidr_block        = "10.10.2.0/24"
  map_public_ip_on_launch = true
}

module "subnet-private-a" {
  source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//subnet"
  subnet_name       = "subnet_private_a_spfarm_staging"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id            = "${module.vpc_spfarm_staging.id}"
  cidr_block        = "10.10.3.0/24"
  map_public_ip_on_launch = false
}

module "subnet-private-b" {
  source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//subnet"
  subnet_name       = "subnet_private_b_spfarm_staging"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  vpc_id            = "${module.vpc_spfarm_staging.id}"
  cidr_block        = "10.10.4.0/24"
  map_public_ip_on_launch = false
}

  resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id          = "${module.vpc_spfarm_staging.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.dns_resolver.id}"
  }

  resource "aws_vpc_dhcp_options" "dns_resolver" {
    domain_name         = "sposcar.local"
    domain_name_servers = [
      "${aws_instance.SP-DC1.private_ip}"
      # "${aws_directory_service_directory.spfarm_ad.dns_ip_addresses[1]}",
      # "${aws_instance.SP-DC1.private_ip}"
    ]
    tags {
      Name = "spfarm_dns_resolver_servers"
    }
  } 




// module "elb_spfarm_staging" {
//   source                    = "github.com/SharePointOscar/terraform_modules.git//aws_modules//elb"
//   elb_name                  = "elb-spfarm-test"
//   subnets                   = ["${module.subnet-public-a.id}"]
//   internal                  = false
//   security_groups           = ["${module.elb_security_group.id}"]
//   instance_port             = 80
//   instance_protocol         = "tcp"
//   lb_port                   = 80
//   lb_protocol               = "tcp"
//   healthy_threshold         = 2
//   unhealthy_threshold       = 2
//   timeout                   = 3
//   target                    = "TCP:80"
//   interval                  = 30
//   cross_zone_load_balancing = trueus
// }

module "spfarmkeypair" {
  source     = "github.com/SharePointOscar/terraform_modules.git//aws_modules//key_pair"
  key_name   = "spfarm_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqYi2H1kIifIq5VtI4lQmB+T1/FUnwXYKUeXjze1h6R7J2hv6wvjzSkyIVgySGJr16QQWG8g8lHdjF19QAo+icbLn3UHhuDYlgbE26Ag0qZ5DhD6SCMk30rqsnJascCRfy4JEy23WhkjNACJtiwyVqSGP78XMb3Khwo5tVVqbGv+AjvfPQHmvNF02Lxu7dIBjAROFkGqZnYkD9v/NNIXjmEmy6oL5VfncmIMeasMoWuYPkAah6sTc6SHtqUQ4oyCMp6cwYvTLsGc39uWhv+VBuN6g5gLwmvIE4g5cVL/adPgdxgNej06Jo6Th9F+3CgfFUahEfotsn/R3hCVDbrfTb jenkins"
}


