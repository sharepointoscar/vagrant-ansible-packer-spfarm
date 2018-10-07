# Create a virtual network 
resource "azurerm_virtual_network" "spfarmstaging-vnet" {
  name                = "spfarm_staging_network"
  address_space       = ["10.10.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  address_space       = ["10.10.0.0/16"]
  location            = "${var.azure_location}"

}

module "subnet-backend" {
  
  source                    = "github.com/SharePointOscar/terraform_modules.git//azure_modules//GatewaySubnet"
  sb_name                   = "spfarm-subnet-backend"
  rg_name                   = "${var.resource_group_name}"
  vnet_name                 = "${azurerm_virtual_network.spfarmstaging-vnet.name}"
  sb_addr_prefix            = "10.10.1.0/24"

}

module "subnet-application" {

  source                    = "github.com/SharePointOscar/terraform_modules.git//azure_modules//GatewaySubnet"
  sb_name                   = "spfarm-subnet-application"
  rg_name                   = "${var.resource_group_name}"
  vnet_name                 = "${azurerm_virtual_network.spfarmstaging-vnet.name}"
  sb_addr_prefix            = "10.10.2.0/24"

}

resource "azurerm_subnet" "subnet-frontend" {
  name                 = "spfarm-subnet-frontend"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.spfarmstaging-vnet.name}"
  address_prefix       = "10.10.3.0/24"
}

# Create Network Security Group and rule for backend
resource "azurerm_network_security_group" "spfarm-security-group-backend" {
    name                = "spfarm-security-group-backend"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    
      # allow SSH connections
      security_rule {
          name                       = "SSH"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
      }

      # allow WinRM connections
      security_rule {
          name                       = "WinRM"
          priority                   = 1002
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5985"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
      }   

      # allow RDP connections
      security_rule {
          name                       = "RDP"
          priority                   = 1003
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
      }  

    tags {
        environment = "Terraform Demo"
    }
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "spfarm-security-group-frontend" {
    name                = "spfarm-security-group-frontend"
    location            = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    
      # allow SSH connections
      security_rule {
          name                       = "SSH"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
      }

      # allow WinRM connections
      security_rule {
          name                       = "WinRM"
          priority                   = 1002
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5985"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
      }   

      # allow RDP connections
      security_rule {
          name                       = "RDP"
          priority                   = 1003
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "3389"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
      }  

    tags {
        environment = "Terraform Demo"
    }
}

# DB1 Network settings
 resource "azurerm_public_ip" "db1-public-ip" {
  name                         = "db1-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"

  tags {
    environment = "staging"
  }
}
resource "azurerm_network_interface" "spfarm-db1" {
  name                      = "network-interface-spfarm-db1"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  network_security_group_id = "${azurerm_network_security_group.spfarm-security-group-backend.id}"
  dns_servers               = ["10.10.1.19"]

  ip_configuration {
    name                          = "db1-ipconfiguration"
    subnet_id                     = "${module.subnet-backend.id}"
    public_ip_address_id          = "${azurerm_public_ip.db1-public-ip.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.1.17"
  }

  tags {
    environment = "Staging"
  }
}

resource "azurerm_public_ip" "appserver1-public-ip" {
  name                         = "appserver1-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  
  tags {
    environment = "SharePoint 2016 Staging"
  }
}

resource "azurerm_network_interface" "spfarm-appserver1" {

  name                          = "network-interface-spfarm-appserver1"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  network_security_group_id     = "${azurerm_network_security_group.spfarm-security-group-backend.id}"  
  dns_servers                   = ["10.10.1.19"]
  
  ip_configuration {
    name                          = "appserver1-ipconfiguration"
    subnet_id                     = "${module.subnet-application.id}"
    public_ip_address_id          = "${azurerm_public_ip.appserver1-public-ip.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.2.18"

  }

  tags {
    environment = "SharePoint 2016 Staging"
  }
} 

# WFE1 Network settings
resource "azurerm_public_ip" "wfe-public-ip" {
  count                        = 2
  name                         = "wfe${count.index}-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  
  tags {
    environment = "SharePoint 2016 Staging"
  }
}

resource "azurerm_network_interface" "spfarm-wfe" {

  count                                   = 2
  name                                    = "network-interface-spfarm-wfe${count.index}"
  location                                = "${var.location}"
  resource_group_name                     = "${var.resource_group_name}"
  network_security_group_id               = "${azurerm_network_security_group.spfarm-security-group-frontend.id}"
  dns_servers                             = ["10.10.1.19"]

  ip_configuration {
    name                          = "wfe${count.index}-ipconfiguration"
    subnet_id                     = "${azurerm_subnet.subnet-frontend.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.3.${count.index + 4}"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
    load_balancer_inbound_nat_rules_ids = ["${element(azurerm_lb_nat_rule.NatRule0.*.id, count.index)}"]
  }

   tags {
    environment = "Staging"
  }
}


# AD1 Network settings
resource "azurerm_public_ip" "ad1-public-ip" {
  name                         = "ad1-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  
  
  tags {
     environment = "SharePoint 2016 Staging"
  }
}
resource "azurerm_network_interface" "spfarm-ad1" {
  name                = "network-interface-spfarm-ad1"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  network_security_group_id = "${azurerm_network_security_group.spfarm-security-group-backend.id}"

  ip_configuration {
    name                          = "AD1-ipconfiguration"
    subnet_id                     = "${module.subnet-backend.id}"
    public_ip_address_id          = "${azurerm_public_ip.ad1-public-ip.id}"
    private_ip_address_allocation = "static"
    private_ip_address            = "10.10.1.19"
  }

   tags {
    environment = "SharePoint 2016 Staging"
  }
}
