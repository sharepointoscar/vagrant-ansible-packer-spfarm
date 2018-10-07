#!/usr/bin/env bash
set -e
azure_client_id=
azure_object_id=
azure_client_id=$(az ad sp list | jq -r '.[] | select(.displayName | contains("spfarmstaging")) .appId')

if [ "$azure_client_id" != "" ]; then
    echo "==> deleting service principal..."
    az ad sp delete --id "$azure_client_id"

    # delete the application
    #az ad app list | jq -r '.[] | select(.displayName | contains("'$meta_name'")) .appId'
    echo "==> deleting application"
    azure_object_id=$(az ad sp list | jq -r '.[] | select(.displayName | contains("spfarmstaging")) .objectId' )
    az ad app delete --id "$azure_object_id"
    
    echo "==> deleting deleting storage account"
    #az storage account list | jq -r '.[] | select( .name) | .name ' 
    az storage delete -n "spfarmstaging" -g "spfarmstaging"
else
    echo "==> resources do not exist...done."

fi



