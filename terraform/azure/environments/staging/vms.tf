
resource "azurerm_virtual_machine" "spfarm_appserver1" {
  name                  = "sp2016AppServer"
  location              = "${var.azure_location}"
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "Standard_DS2_v2"
  network_interface_ids = ["${azurerm_network_interface.spfarm-appserver1.id}"]
    
  # Tells Terraform that this VM   must be created only after the
  # Domain Controller has been created.
  depends_on = ["azurerm_virtual_machine.spfarm_ad1"]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    name          = "APPSERVER1-osdisk1"
    os_type       = "Windows"
    caching       = "ReadWrite"
    image_uri     = "${var.os_disk_vhd_uri}"
    vhd_uri       = "https://${var.storage_account}.blob.core.windows.net/${var.container_name}/appserver1-osdisk.vhd"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "sp2016AppServer"
    admin_username = "packer"
    admin_password = "pass@word1!"
  }

  os_profile_windows_config {
        provision_vm_agent = true
        enable_automatic_upgrades = true

    } 

}

resource "azurerm_virtual_machine" "spfarm_db1" { 
  name                  = "SP2016SQLSERVER"
  location              = "${var.azure_location}"
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "Standard_DS2_v2"
  network_interface_ids = ["${azurerm_network_interface.spfarm-db1.id}"]
  
  # Tells Terraform that this VM   must be created only after the
  # Domain Controller has been created.
  depends_on = ["azurerm_virtual_machine.spfarm_ad1"]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

 storage_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "SQL2014SP2-WS2012R2"
    sku       = "Enterprise"
    version   = "latest"
  }
  storage_os_disk {
    name          = "DB1-osdisk1"
    os_type       = "Windows"
    caching       = "ReadWrite"
    vhd_uri       = "https://${var.storage_account}.blob.core.windows.net/${var.container_name}/DB1-osdisk.vhd"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "SP2016SQLSERVER"
    admin_username = "packer"
    admin_password = "pass@word1!"
  }

  os_profile_windows_config {
        provision_vm_agent = true
        enable_automatic_upgrades = true

    } 

/*   provisioner "remote-exec" {
    connection = {
     type        = "winrm"
     user        = "packer"
     password    = "pass@word1!"
     agent       = "false"
     host        = "${azurerm_public_ip.db1-public-ip.ip_address}"
    }
    inline = ["powershell.exe Set-ExecutionPolicy RemoteSigned -force","powershell.exe -version 4 -ExecutionPolicy Bypass Restart-Computer"]
  }  */
} 
resource "azurerm_availability_set" "WebFrontEnd_AvailabilitySet" {

  name                         = "WebFrontEnd_AvailabilitySet"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = false

} 
resource "azurerm_virtual_machine" "spfarm_wfe1" {
  name                  = "SP2016WFE"
  location              = "${var.azure_location}"
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "Standard_DS2_v2"
 
  network_interface_ids = ["${element(azurerm_network_interface.spfarm-wfe.*.id, count.index)}"]
  availability_set_id   = "${azurerm_availability_set.WebFrontEnd_AvailabilitySet.id}" 

 # Uncomment this line to delete the OS disk automatically when deleting the VM
 # delete_os_disk_on_termination = true

 # Uncomment this line to delete the data disks automatically when deleting the VM
 delete_data_disks_on_termination = true

   storage_os_disk {
    name          = "WFE${count.index}-osdisk1"
    os_type       = "Windows"
    caching       = "ReadWrite"
    image_uri     = "${var.os_disk_wfe_vhd_uri}"
    vhd_uri       = "https://${var.storage_account}.blob.core.windows.net/${var.container_name}/wfe${count.index}-osdisk.vhd"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "SP2016WFE${count.index}"
    admin_username = "packer"
    admin_password = "pass@word1!"
  }

  os_profile_windows_config {
        provision_vm_agent = true
        enable_automatic_upgrades = true
  } 

  
}


resource "azurerm_virtual_machine" "spfarm_ad1" {
  name                  = "SP2012R2AD"
  location              = "${var.azure_location}"
  resource_group_name   = "${var.resource_group_name}"
  vm_size               = "Standard_DS2_v2"
  network_interface_ids = ["${azurerm_network_interface.spfarm-ad1.id}"]
  
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true


  storage_os_disk {
    name          = "AD1-osdisk1"
    os_type       = "Windows"
    caching       = "ReadWrite"
    image_uri     = "${var.os_disk_vhd_uri}"
    vhd_uri       = "https://${var.storage_account}.blob.core.windows.net/${var.container_name}/AD1-osdisk.vhd"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "SP2012R2AD"
    admin_username = "packer"
    admin_password = "pass@word1!"
  }

  os_profile_windows_config {
        provision_vm_agent = true
        enable_automatic_upgrades = true
    } 

}
