Stouts.sudo
===========

[![Build Status](https://travis-ci.org/Stouts/Stouts.sudo.png)](https://travis-ci.org/Stouts/Stouts.sudo)

Ansible role which manage sudoers file

#### Variables
```yaml
sudo_enabled: yes                               # Enable role
sudo_users: []                                  # A list of users who have sudo access
sudo_groups: [admin, sudo]                      # A list of groups who have sudo access
sudo_passwordless: [admin, sudo]                # A list of group/user names which have NOPASSD
sudo_agent_forwarding: no                       # Preserve `SSH_AUTH_SOCK` when sudoing
sudo_defaults: [!lecture, tty_tickets, !fqdn]   # List of default entries for configuration
sudo_include_sudoersd: no                       # Include /etc/sudoers.d directory
```

#### Usage

Add `Stouts.sudo` to your roles and set vars in your playbook file.

Example:

```yaml

- hosts: all

  roles:
    - Stouts.sudo

  vars:
    sudo_users: [klen]
    sudo_passwordless: [klen]

```

#### License

Licensed under the MIT License. See the LICENSE file for details.

#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/Stouts/Stouts.sudo/issues)!

