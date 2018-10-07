## ANXS - openssh [![Build Status](https://travis-ci.org/ANXS/openssh.png)](https://travis-ci.org/ANXS/openssh)

Ansible role which installs and configures openssh.


#### Requirements & Dependencies
- Tested on Ansible 1.4 or higher.


#### Variables

```yaml
openssh_client_settings: ...
openssh_server_settings: ...
```

See the [defaults](defaults/main.yml) to have the complete view. Make sure, if you edit them, to copy all of them in your host/vars/... files, and change the ones that need tweaking (it's in fact only one variable, containing a map.)


#### License

Licensed under the MIT License. See the LICENSE file for details.


#### Feedback, bug-reports, requests, ...

Are [welcome](https://github.com/ANXS/openssh/issues)!
