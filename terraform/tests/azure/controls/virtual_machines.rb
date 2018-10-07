
control 'azure_spfarm_virtual_machines' do
  title 'Verify the SharePoint 2016 Farm Virtual Machines are configured as required.'
  impact 1.0

  describe azure_virtual_machine(group_name: 'spfarmstaging', name: 'sp2016AppServer') do

    # Check if the VM is located in the correct region
    its('location') { should cmp 'westus' }

     # should have nics attached to it
    it { should have_nics }

    # The Public Address Network Interface should exist
    its('nic_count') {should eq 1}

    # Check if the VM has the correct size
    its('vm_size') { should cmp 'Standard_DS2_v2' }

    # Check if the VM has tags
    #it { should have_tags }
  end
  describe azure_virtual_machine(group_name: 'spfarmstaging', name: 'SP2016SQLSERVER') do
   

    # Check if the VM is located in the correct region
    its('location') { should cmp 'westus' }

    # should have nics attached to it
    it { should have_nics }

    # The Public Address Network Interface should exist
    its('nic_count') {should eq 1}

    # Check if the VM has the correct image
    its('publisher') { should cmp 'MicrosoftSQLServer' }
    its('offer') { should cmp 'SQL2014SP2-WS2012R2' }
    its('sku') { should cmp 'Enterprise' }

    # Check if the VM has the correct size
    its('vm_size') { should cmp 'Standard_DS2_v2' }

    # Check if the VM has the correct admin username
    its('admin_username') { should eq 'packer' }


    # Check if the VM has tags, as per business requirements
    #it { should have_tags }
  end
end
