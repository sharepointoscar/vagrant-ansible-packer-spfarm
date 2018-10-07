output "vnet_id" {
  value = "${azurerm_virtual_network.spfarmstaging-vnet.id}"
}
output "vnet_name" {
  value = "${azurerm_virtual_network.spfarmstaging-vnet.name}"
}
output "vnet_resource_group" {
  value = "${azurerm_virtual_network.spfarmstaging-vnet.resource_group_name}"
}
output "vnet_address_space" {
  value = "${azurerm_virtual_network.spfarmstaging-vnet.address_space}"
}

output "vnet_location" {
  value = "${azurerm_virtual_network.spfarmstaging-vnet.location}"
}

output "db1-public-ip" {
    value = "${azurerm_public_ip.db1-public-ip.ip_address}"
}
output "ad1-public-ip" {
    value = "${azurerm_public_ip.ad1-public-ip.ip_address}"
}


output "appserver1-public-ip" {
    value = "${azurerm_public_ip.appserver1-public-ip.ip_address}"
}

output "azurerm_network_interface.spfarm-db1.dns_servers" {
    value = "${azurerm_network_interface.spfarm-db1.applied_dns_servers}"
}

output "azurerm_network_interface.spfarm-appserver1.dns_servers" {
    value = "${azurerm_network_interface.spfarm-appserver1.applied_dns_servers}"
}




