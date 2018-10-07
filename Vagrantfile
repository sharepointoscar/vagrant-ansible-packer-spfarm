# -*- mode: ruby -*-
# vi: set ft=ruby :

  # TOPOLOGY - this topology is for a Small Non-High Availability MinRole Farm comprised of two servers plus
  # Domain Controller and:
  # a) WFE / Distributed Cache
  # b) Application with Search Server
  # for more details on SharePoint Topologies https://technet.microsoft.com/en-us/library/mt743704(v=office.16).aspx
  # also, be sure to take a look at the HOWTOUSE.md on this repository.

require 'yaml'
require 'json'

error = Vagrant::Errors::VagrantError

# The vagrant-machines.yaml is at the heart of this solution; it is where we define the servers
# and their respective roles for the SharePoint farm.  Update this file first, when scaling the farm.
machines = YAML.load_file 'vagrant-machines.yaml'
ANSIBLE_RAW_SSH_ARGS = []

#delete the inventory file if it exists so we can recreate
File.exists? "ansible/hosts_dev_env.yaml"

# Generate the Ansible Inventory file dynamically and yes, based on the defined machines
# from the vagrant-machines.yaml
File.open("ansible/hosts_dev_env.yaml" ,'w') do |f|
  machines.each do |machine|
    f.write "#{machine[0]}:\n"
    f.write "   hosts:\n"
    f.write "     #{machine[1]['name']}:\n"
    f.write "       ansible_ssh_host: #{machine[1]['ip_address']}\n"
    f.write "       ansible_user: vagrant\n"
    f.write "       ansible_password: vagrant\n"
    f.write "       hostname: #{machine[1]['hostname']}\n"
  end
end


Vagrant.configure(2) do |config|

  config.vm.box_check_update = false

  machines.each do |machine|
   
    name = machine[1]['name']
    box =  machine[1]['box']
    role = machine[1]['role']
    hostname = machine[1]['hostname']

    providers = machine[1]['providers']
    memory = machine[1]['memory'] || '512'
    default = machine[1]['default'] || false
    ip_address = machine[1]['ip_address']

    # insert the private key from the host machine to the guest
    ANSIBLE_RAW_SSH_ARGS << "-o IdentityFile=~/.vagrant.d/insecure_private_key"


    fail error.new, 'machines must contain a name' if name.nil?

    config.vm.define name, primary: default, autostart: default do |cfg|
    cfg.vm.hostname = hostname
        # credentials
    cfg.winrm.username = "vagrant"
    cfg.winrm.password = "vagrant"
    cfg.vm.guest = :windows
    cfg.vm.communicator = "winrm"
    cfg.windows.halt_timeout = 35
    cfg.vm.boot_timeout = 800

    #configure the network for this machine
    cfg.vm.network "private_network", ip: ip_address
    cfg.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    
      if box
        cfg.vm.box = box
      elsif box_url && box_name
        cfg.vm.box = box_name
        cfg.vm.box_url = box_url
      else
        fail error.new, 'machines must contain box or box_name and box_url'
      end

      if providers == 'virtualbox'
        cfg.vm.provider :virtualbox do |v|
          v.gui = true
          v.customize ["modifyvm", :id, "--memory", memory]
          v.customize ["modifyvm", :id, "--cpus", 2]
          v.customize ["modifyvm", :id, "--vram", 128]
          v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
          v.customize ["modifyvm", :id, "--accelerate3d", "on"]
          v.customize ["modifyvm", :id, "--accelerate2dvideo", "on"]
        end
      end

      # disable UAC for all boxes - this will be done using Packer, for now do it here.
      cfg.vm.provision "shell", path: "./ansible/roles/internal/common/files/provision_settings.ps1"

      # Use specific Ansible Playbooks and other provisioners based on SP Machine Role
      if role == 'DomainController'
        cfg.vm.provision :ansible do |ansible|
            #let's configure the domain controler and add
            # a) the SP Service Accounts
            # b) Sample User Accounts
            ansible.limit = "DomainControllers"
            ansible.playbook = "ansible/plays/domaincontroller.yml"
            ansible.inventory_path = "ansible/hosts_dev_env.yaml"
            ansible.verbose = "vvvv"
            # we need the following line to ensure ansible does not fail
            # when bringing up the vagrant domain vs an aws hosted one.  cloud_host variable must be defined
            # basically
            ansible.extra_vars = { 
              "cloud_host" => "DomainControllers" 
            }
            ansible.raw_ssh_args = ANSIBLE_RAW_SSH_ARGS
           end
        # Run ServerSpec Tests for Domain Controller
        cfg.vm.provision :serverspec do |spec|
          spec.pattern = 'spec/SP2012R2AD.sposcar.local/ad_spec.rb'
        end
      elsif role == 'Front-End'
       # we must set the network interface DNS server accordingly
        # before we join the machien to the domain
        config.vm.provision "shell", path: "./ansible/roles/internal/DomainController/files/SetDNS.ps1", args:"-DNS 192.168.2.19 -Network 192.168.2.16"

        cfg.vm.provision :ansible do |ansible|
          ansible.limit = "Webservers"
          ansible.playbook = "ansible/plays/webservers.yml"
          ansible.inventory_path = "ansible/hosts_dev_env.yaml"
          ansible.verbose = "vvvv"
          ansible.extra_vars = { 
            "cloud_host" => "Webservers"
          }
          ansible.raw_ssh_args = ANSIBLE_RAW_SSH_ARGS
        end
      elsif role == 'Database'
        
       # we must set the network interface DNS server accordingly
        # before we join the machien to the domain
        config.vm.provision "shell", path: "./ansible/roles/internal/DomainController/files/SetDNS.ps1", args:"-DNS 192.168.2.19 -Network 192.168.2.17"

        cfg.vm.provision :ansible do |ansible|
          ansible.limit = "Databases"
          ansible.playbook = "ansible/plays/databaseservers.yml" 
          ansible.inventory_path = "ansible/hosts_dev_env.yaml"
          ansible.verbose = "vvvvv"
          ansible.extra_vars = { 
            "cloud_host" => "Databases"
          }
          ansible.raw_ssh_args = ANSIBLE_RAW_SSH_ARGS
        end
      elsif role == 'Application'
       
        # we must set the network interface DNS server accordingly
         # before we join the machien to the domain
         config.vm.provision "shell", path: "./ansible/roles/internal/DomainController/files/SetDNS.ps1", args:"-DNS 192.168.2.19 -Network 192.168.2.18"
 
         cfg.vm.provision :ansible do |ansible|
           ansible.limit = "AppServers"
           ansible.playbook = "ansible/plays/appservers.yml" 
           ansible.inventory_path = "ansible/hosts_dev_env.yaml"
           ansible.verbose = "vvvv"
           ansible.raw_ssh_args = ANSIBLE_RAW_SSH_ARGS
         end
      end
    end
  end
end
