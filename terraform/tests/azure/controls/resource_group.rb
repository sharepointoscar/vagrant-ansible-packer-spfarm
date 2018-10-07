control 'azure_spfarm_storage' do
    title 'Verify the SharePoint 2016 Farm Azure primary Resource Group configuration.'
    impact 1.0
  
  describe azure_resource_group(name: 'spfarmstaging') do

    # Check if the number of VMs in the Resource Group is correct (for SharePoint 2016 topology we have 4)
    its('vm_count') { should eq 4 }

    # Check if the number of public IPs is correct, should be 4 one for each VM
    its('public_ip_count') { should eq 4 }

    its('name') { should eq 'spfarmstaging' }

    #storage should be in the West US
    its('location') { should cmp 'westus' } 

    # We have two NSGs for our solution
    its('nsg_count') { should eq 2 }

  end
end