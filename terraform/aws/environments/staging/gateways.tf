#
# NAT Gateway in AZ1
#

resource "aws_nat_gateway" "natgw_az1" {

	allocation_id = "${aws_eip.eip_natgw_az1.id}"
	subnet_id = "${module.subnet-public-a.id}"

	depends_on = ["aws_internet_gateway.internet_gateway"]

}

#
# NAT Gateway in AZ2
#

resource "aws_nat_gateway" "natgw_az2" {

	allocation_id = "${aws_eip.eip_natgw_az2.id}"
	subnet_id = "${module.subnet-public-b.id}"

	depends_on = ["aws_internet_gateway.internet_gateway"]

}