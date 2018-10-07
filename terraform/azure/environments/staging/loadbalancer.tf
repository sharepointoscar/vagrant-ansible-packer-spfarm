
# Load Balancers and associated pools
resource "azurerm_lb" "WebFrontEnd_LB" {
  name                = "WebFrontEnd_LB"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                          = "Web-LB-FrontEnd"
    public_ip_address_id          = "${azurerm_public_ip.webfrontend-lb-public-ip.id}"
  
  }

}

resource "azurerm_public_ip" "webfrontend-lb-public-ip" {
  name                         = "webfrontend-lb-public-ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  
  tags {
    environment = "SharePoint 2016 Staging"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.WebFrontEnd_LB.id}"
  name                = "Web-LB-BackendPool"
}
/* resource "azurerm_lb_nat_pool" "lbnatpool" {
  count                          = 2
  resource_group_name            = "${var.resource_group_name}"
  name                           = "ssh"
  loadbalancer_id                = "${azurerm_lb.WebFrontEnd_LB.id}"
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "Web-LB-FrontEnd"


} */

# LB Probes
resource "azurerm_lb_probe" "lbprobe443" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.WebFrontEnd_LB.id}"
  name                = "lbprobe443"
  port                = 443
  
}

resource "azurerm_lb_probe" "lbprobe80" {
  resource_group_name = "${var.resource_group_name}"
  loadbalancer_id     = "${azurerm_lb.WebFrontEnd_LB.id}"
  name                = "lbprobe80"
  port                = 80
}


# LB Rules
resource "azurerm_lb_rule" "lbrule443" {
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.WebFrontEnd_LB.id}"
  name                           = "lbrule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
  probe_id                       = "${azurerm_lb_probe.lbprobe443.id}"
  frontend_ip_configuration_name = "Web-LB-FrontEnd"

}

resource "azurerm_lb_rule" "lbrule80" {
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.WebFrontEnd_LB.id}"
  name                           = "lbrule80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
  probe_id                       = "${azurerm_lb_probe.lbprobe80.id}"
  frontend_ip_configuration_name = "Web-LB-FrontEnd"

}

# NAT Rules to allow access to each VM
resource "azurerm_lb_nat_rule" "NatRule0" {
  name                           = "NatRule-${count.index}"
  resource_group_name            = "${var.resource_group_name}"
  loadbalancer_id                = "${azurerm_lb.WebFrontEnd_LB.id}"
  protocol                       = "tcp"
  frontend_port                  = "5985${count.index + 1}"
  backend_port                   = 5985
  frontend_ip_configuration_name = "Web-LB-FrontEnd"
  count                          = 2
  depends_on                     = ["azurerm_lb.WebFrontEnd_LB"]
}

// resource "azurerm_lb_nat_rule" "nat-winRM-wfe0" {
//   resource_group_name            = "${var.resource_group_name}"
//   loadbalancer_id                = "${azurerm_lb.WebFrontEnd_LB.id}"
//   name                           = "nat-winRM-wfe0"
//   protocol                       = "Tcp"
//   frontend_port                  = 5985
//   backend_port                   = 5985
//   frontend_ip_configuration_name = "Web-LB-FrontEnd"
// }
// resource "azurerm_lb_nat_rule" "nat-RDP-wfe0" {
//   resource_group_name            = "${var.resource_group_name}"
//   loadbalancer_id                = "${azurerm_lb.WebFrontEnd_LB.id}"
//   name                           = "nat-RDP-wfe0"
//   protocol                       = "Tcp"
//   frontend_port                  = 3389
//   backend_port                   = 3389
//   frontend_ip_configuration_name = "Web-LB-FrontEnd"
// }