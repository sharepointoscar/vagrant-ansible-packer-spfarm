To get an Windows 2016 Server EC2 instance to work properly, we need to change the EC2 Launch Settings as outlined here
NOTE the new file format and names.

  [EC2 Launch Config/Settings](http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch.html)

  * Use the LaunchConfig.json to set admin password
  * Change SysPrep settings and execute

Windows 2012R2 AMIs still use old settings and xml config.

### Get Previously Created Service Principal Information

Get only the appId property.
```bash
>$ $(az ad app list | jq -r '.[] | select(.displayName | contains("azure-cli-")) | .appId')

echo $(az account list-locations | jq -r '.[] | select(.displayName | contains("West US")) ')
```
Get all of the Service Principal Details
```bash
 echo $(az ad app list | jq -r '.[] | select(.displayName | contains("azure-cli")) ') 
```