ansible-hostname role
=====================

Requirements
------------
tested on Ubuntu 12.04 and ansible > 1.6

### Variables
``` 
## Define what part of fqdn is the hostname lets say "postgresql00.dev.prod.example.com"

# Option (A) We can use subdomain level from left
#     i.e.
#       value "1"  result is "postgresql00"
#       value "3"  result is "postgresql00.de.prod"
#  To enable override somewhere in hostvar or inventory file
hostname_sub_level    :  false
# Option (B) We define top level domain to exclude
#     i.e.
#       value "de.prod.example.com"  result is "postgresql00"
#       value "example.com" result is "postgresql00.de.prod"
#  To enable override somewhere in hostvar or inventory file
hostname_sub_replace  :  false
# Option (C) We do nothing and in just user value in inventory_hostname thats the default

hostname_hosts_file   :
                        - regexp : "^127.0.0.1"
                          line   : "127.0.0.1{{'\t'}}localhost"

                        - regexp : "^127.0.1.1"
                          line   : "127.0.1.1{{ lookup('template', '../templates/hosts_file.j2') }}"
```
