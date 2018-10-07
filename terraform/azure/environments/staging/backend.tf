terraform {
 backend "azurerm" {
   storage_account_name = "spfarmstaging"
   container_name       = "spfarmstaging"
   key                  = "staging-terraform-tfstate"
   access_key           = ""
 }
}
