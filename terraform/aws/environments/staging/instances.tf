##### INSTANCES #####

resource "aws_instance" "SP-AppServer1" {
    ami                         = "${lookup(var.ami, var.region)}"
    availability_zone           = "${data.aws_availability_zones.available.names[0]}"
    instance_type               = "${lookup(var.instance_types_by_role,"AppServer")}"
    monitoring                  = true
    ebs_optimized               = false
    associate_public_ip_address = true
    key_name                    = "${module.spfarmkeypair.key_name}"
    tenancy                     = "default"
    vpc_security_group_ids      = ["${module.sg_spfarm_staging.id}"]
    subnet_id                   = "${module.subnet-public-a.id}"
    user_data                   = "${data.template_file.init.rendered}" 
    private_ip                  = "${lookup(var.private_ip_addresses, "AppServer")}"

    root_block_device = {
        volume_size                 = "50"
        volume_type                 = "gp2"
        iops                        = "100"
        delete_on_termination       = true
    }

    tags = {
        Name              = "SP-AppServer1"
        Role              = "AppServer"
        Group             = "AppServers"
        Environment       = "Staging"
    }
}

resource "aws_instance" "SP-WFE1" {
    ami                         = "${lookup(var.ami, var.region)}"
    availability_zone           = "${data.aws_availability_zones.available.names[1]}"
    instance_type               = "${lookup(var.instance_types_by_role,"WFE")}"
    monitoring                  = true
    ebs_optimized               = false
    associate_public_ip_address = true
    key_name                    = "${module.spfarmkeypair.key_name}"
    tenancy                     = "default"
    vpc_security_group_ids      = ["${module.sg_spfarm_staging.id}"]
    subnet_id                   = "${module.subnet-public-b.id}"
    user_data                   = "${data.template_file.init.rendered}" 
    private_ip                  = "${lookup(var.private_ip_addresses, "WFE")}"

    root_block_device = {
        volume_size                 = "50"
        volume_type                 = "gp2"
        iops                        = "100"
        delete_on_termination       = true
    }

    tags = {
        Name              = "SP-WFE1"
        Role              = "WFE"
        Group             = "WebServers"
        Environment       = "Staging"
    }
}

resource "aws_instance" "SP-DB1" {
    ami                         = "${lookup(var.ami_by_sp_role, "Database")}"
    availability_zone           = "${data.aws_availability_zones.available.names[0]}"
    instance_type               = "${lookup(var.instance_types_by_role,"Database")}"
    monitoring                  = false
    ebs_optimized               = false
    associate_public_ip_address = true
    user_data                   = "${data.template_file.init.rendered}" 
    private_ip                  = "${lookup(var.private_ip_addresses, "Database")}"
    key_name                    = "${module.spfarmkeypair.key_name}"
    tenancy                     = "default"
    vpc_security_group_ids      = ["${module.sg_spfarm_staging.id}"]
    subnet_id                   = "${module.subnet-public-a.id}"
    depends_on                  = ["aws_instance.SP-DC1"]


    root_block_device = {
        volume_size                 = "50"
        volume_type                 = "gp2"
        iops                        = "100"
        delete_on_termination       = true
    }

    tags = {
        Name              = "SP-DB1"
        Role              = "Database"
        Group             = "Databases"
        Environment       = "Staging"
    }
}

resource "aws_instance" "SP-DC1" {

    ami                         = "${lookup(var.ami_by_sp_role, "DomainController")}"
    availability_zone           = "${data.aws_availability_zones.available.names[0]}"
    instance_type               = "${lookup(var.instance_types_by_role,"DomainController")}"
    monitoring                  = false
    ebs_optimized               = false
    associate_public_ip_address = true
    user_data                   = "${data.template_file.init.rendered}" 
    private_ip                  = "${lookup(var.private_ip_addresses, "DomainController")}"
    key_name                    = "${module.spfarmkeypair.key_name}"
    tenancy                     = "default"
    vpc_security_group_ids      = ["${module.sg_spfarm_staging.id}"]
    subnet_id                   = "${module.subnet-public-a.id}"
    iam_instance_profile        = "${aws_iam_instance_profile.instance_profile_adwriter.name}"

    root_block_device {
        volume_size                 = "30"
        volume_type                 = "gp2"
        iops                        = "100"
        delete_on_termination       = true
    }

    tags = {
        Name              = "SP-DC1"
        Role              = "DomainController"
        Group             = "DomainControllers"
        Environment       = "Staging"
    }
}

### INLINE - Bootsrap Windows Server 2012 R2 ###
data "template_file" "init" {
    template = <<EOF
    <script>
        winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"} & winrm/config @{MaxEnvelopeSizekb="8000kb"}
    </script>
    <powershell>
        netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
        $admin = [ADSI]("WinNT://./administrator, user")
        $admin.SetPassword("${var.domain_admin_password}")
    </powershell>
EOF
    vars {
        admin_password = "${var.domain_admin_password}"
    }
}