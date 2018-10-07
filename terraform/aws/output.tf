output "spfarm_WFE1_public_dns" {
  value = "[ ${aws_instance.spfarm_WFE1.public_dns} ]"
}
output "spfarm_AppServer1_public_dns" {
  value = "[ ${aws_instance.spfarm_AppServer1.public_dns} ]"
}
output "spfarm_DomainController1_public_dns" {
  value = "[ ${aws_instance.spfarm_DomainController1.public_dns} ]"
}
output "spfarm_Database1_public_dns" {
  value = "[ ${aws_instance.spfarm_Database1.public_dns} ]"
}

output "spfarm_WFE1 private ip address" {
  value = "${aws_instance.spfarm_WFE1.private_ip}"
}
output "spfarm_AppServer1 private ip address" {
  value = "${aws_instance.spfarm_AppServer1.private_ip}"
}
output "spfarm_DomainController1 private ip address" {
  value = "${aws_instance.spfarm_DomainController1.private_ip}"
}
output "spfarm_Database1 private ip address" {
  value = "${aws_instance.spfarm_Database1.private_ip}"
}

output "spfarm_WFE1 elastic ip" {
  value = "${aws_eip.spfarm_WFE1_ip.public_ip}"
}
output "spfarm_AppServer1 elastic ip" {
  value = "${aws_eip.spfarm_AppServer1_ip.public_ip}"
}
output "spfarm_DomainController1 elastic ip" {
  value = "${aws_eip.spfarm_DomainController1_ip.public_ip}"
}
output "spfarm_Database1 elastic ip" {
  value = "${aws_eip.spfarm_Database1_ip.public_ip}"
}