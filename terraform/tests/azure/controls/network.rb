# load data from Terraform output
content = inspec.profile.file("terraform.json")
params = JSON.parse(content)

# store vnet in variable
VNET_ID = params['vnet_id']['value']
VNET_NAME = params['vnet_name']['value']
VNET_ADDRESS_SPACE = params['vnet_address_space']['value']
NGS_SECURITY_RULES =

control 'check-securityRules' do

    describe azure_generic_resource(group_name: 'spfarmstaging' ,
        name: 'spfarm-security-group-backend', 
        type: 'Microsoft.Network/networkSecurityGroups') do

            its('name') {should cmp 'spfarm-security-group-backend'}
            its('location') {should cmp 'westus'}
            its('properties.securityRules.count') { should eq  3 }   

          # ideally we want to test NSG Rules, not quite possible
          # with the version of InSpec at the moment 
                
    end
end

# control 'Azure_Networking' do

#     title 'Verify the SharePoint 2016 Azure networking infrastructure.'
#     impact 1.0
  
#     # verify the NSG basic settings
#     describe azure_generic_resource(group_name: 'spfarmstaging', name: 'azurerm_network_security_group.spfarm-security-group-backend') do
      
#         # NSG should exist in the West US Region
#         its('location') { should cmp 'westus' }

#         # NSG should be in the correct resource group
#         its('name') { should eq 'spfarmstaging'}
        
#     end

#     # Check that the virtual network is in the West US  
#     describe azure_generic_resource(group_name: 'spfarmstaging', name: 'azurerm_virtual_network') do
      
#         # vNET should exist in the West US Region
#         its('location') { should cmp 'westus' }
       
#     end

#   end

