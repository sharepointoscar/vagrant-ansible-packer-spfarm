# Usage Workflow

This project allows you to follow a workflow when provisioning SharePoint infrastructure as code and maintaining said infrastructure.  Below are general ordered steps to follow.

NOTE: This entire project is under source control, therefore any changes in infrastructure or configuration will be versioned, making it easy to revert back to a previous state.

**Plan**
This phase is focused on building and refining the SharePoint Farm Virtual Machines using the open source tool Packer from HashiCorp.  Packer is a tool for building machine images, for a repeatable, predictable workflow.

>Packer is easy to use and automates the creation of any type of machine image. It embraces modern configuration management by encouraging you to use automated scripts to install and configure the software within your Packer-made images. Packer brings machine images into the modern age, unlocking untapped potential and opening new opportunities.

>    ~Packer.io

* Use Vagrant to build farm servers locally
  * Build farm server roles topology
  * Use Ansible to install SharePoint Bits on each server
  * Use Ansible to install SQL Server on the SQL Role
  * Use Ansible to install and provision Active Directory on Domain Controller Role

* Test Vagrant Boxes by building them locally

**Running Ansible Adhoc Commands against Windows 2016 Server**

To run _playbooks_ manually, you should be in the root of the repo.  An example to execute based on my environment is:

```bash
PYTHONUNBUFFERED=1 ANSIBLE_FORCE_COLOR=true ANSIBLE_HOST_KEY_CHECKING=false ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -i '/Users/sharepointoscar/.vagrant.d/insecure_private_key' -o IdentityFile=~/.vagrant.d/insecure_private_key  ControlMaster=auto -o ControlPersist=60s' ansible-playbook --connection=ssh --timeout=30 --extra-vars="ansible_ssh_user='vagrant'" --limit="domaincontrollers" --inventory-file=ansible/test.ini -vvvv ansible/plays/domaincontroller.yml --start-at-task="Create directory structure"

```

**Test**

Once all the Vagrant machines are defined and created, we run our tests against them via the _ServerSpec_ Provisioner
* Use `vagrant up` to bring up all machines which are part of the farm
* The _ServerSpec_ Provisioner takes care of running the tests for each box
* Things to check
  * Ports open
  * Server has specific software installed
  * Ping machine?


**Deploy**

We use Terraform to Deploy our infrastructure to either Azure or AWS.  The definitions for both are under the Terraform folder within this project.
