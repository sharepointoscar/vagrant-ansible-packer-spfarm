##### SECURITY GROUP CONFIGURATIONS #####
module "sg_spfarm_staging" {
    source  = "github.com/SharePointOscar/terraform_modules.git//aws_modules//security_group"
    sg_name = "sg_spfarm_staging"
    vpc_id  = "${module.vpc_spfarm_staging.id}"
}

# allow ssh connections
module "spfarm_staging_ssh_rule" {
    source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//security_group_rule"
    type              = "ingress"
    to_port           = 22
    from_port         = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${module.sg_spfarm_staging.id}"
}

# allow intra security group traffic
module "spfarm_staging_all_internal_rule" {
    source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//security_group_rule"
    type              = "ingress"
    to_port           = 0
    from_port         = 0
    protocol          = "-1"
    cidr_blocks       = ["10.10.0.0/16"]
    security_group_id = "${module.sg_spfarm_staging.id}"
}

# allow winRM connections
module "spfarm_staging_winrm_rule" {
    source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//security_group_rule"
    type              = "ingress"
    to_port           = 5985
    from_port         = 5985
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${module.sg_spfarm_staging.id}"
}

# allow rdp connections
module "spfarm_staging_rdp_rule" {
    source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//security_group_rule"
    type              = "ingress"
    to_port           = 3389
    from_port         = 3389
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${module.sg_spfarm_staging.id}"
}

# allow ping
module "spfarm_staging_ping_ingress_rule" {
    source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//security_group_rule"
    type              = "ingress"
    from_port         = -1
    to_port           = -1
    protocol          = "icmp"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${module.sg_spfarm_staging.id}"
}

module "spfarm_staging_all_egress_rule" {
    source            = "github.com/SharePointOscar/terraform_modules.git//aws_modules//security_group_rule"
    type              = "egress"
    from_port   = 0
    to_port     = 65535
    protocol    = "all"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = "${module.sg_spfarm_staging.id}"
}