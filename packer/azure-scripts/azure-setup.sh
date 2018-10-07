#!/usr/bin/env bash
set -e

meta_name=
azure_client_id=       # Derived from application after creation
azure_client_secret=   # Application password
azure_group_name=
azure_storage_name=
azure_subscription_id= # Derived from the account after login
azure_tenant_id=       # Derived from the account after login
location=
azure_object_id=
azureversion=
create_sleep=10

showhelp() {
    echo "az-setup"
    echo ""
    echo "  az-setup helps you generate packer credentials for az"
    echo ""
    echo "  The script creates a resource group, storage account, application"
    echo "  (client), service principal, and permissions and displays a snippet"
    echo "  for use in your packer templates."
    echo ""
    echo "  For simplicity we make a lot of assumptions and choose reasonable"
    echo "  defaults. If you want more control over what happens, please use"
    echo "  the az-cli directly."
    echo ""
    echo "  Note that you must already have an az account, username,"
    echo "  password, and subscription. You can create those here:"
    echo ""
    echo "  - https://account.windowsazure.com/"
    echo ""
    echo "REQUIREMENTS"
    echo ""
    echo "  - az-cli"
    echo "  - jq"
    echo ""
    echo "  Use the requirements command (below) for more info."
    echo ""
    echo "USAGE"
    echo ""
    echo "  ./az-setup.sh requirements"
    echo "  ./az-setup.sh setup"
    echo ""
}

requirements() {
    found=0

    if azureversion=$(az -v); then
        found=$((found + 1))
        echo "Found az-cli version: $azureversion"
    else
        echo "az cli is missing. Please install az cli from"
        echo "https://az.microsoft.com/en-us/documentation/articles/xplat-cli-install/"
    fi

    if jqversion=$(jq --version); then
        found=$((found + 1))
        echo "Found jq version: $jqversion"
    else
        echo "jq is missing. Please install jq from"
        echo "https://stedolan.github.io/jq/"
    fi

    if [ $found -lt 2 ]; then
        exit 1
    fi
}

askSubscription() {
    az account list
    echo ""
    echo "Please enter the Id of the account you wish to use. If you do not see"
    echo "a valid account in the list press Ctrl+C to abort and create one."
    echo "If you leave this blank we will use the Current account."
    echo -n "> "
    read -r azure_subscription_id

    if [ "$azure_subscription_id" != "" ]; then
        az account set --subscription "$azure_subscription_id"
    else
        azure_subscription_id=$(az account list | jq -r .[].id)
    fi
    azure_tenant_id=$(az account list | jq -r '.[] | select(.tenantId) |  .tenantId') 
    echo "Using subscription_id: $azure_subscription_id"
    echo "Using tenant_id: $azure_tenant_id"
}

askName() {
    echo ""
    echo "Choose a name for your resource group, storage account and client"
    echo "client. This is arbitrary, but it must not already be in use by"
    echo "any of those resources. ALPHANUMERIC ONLY. Ex: mypackerbuild"
    echo -n "> "
    read -r meta_name
}

askSecret() {
    echo ""
    echo "Enter a secret for your application. We recommend generating one with"
    echo "openssl rand -base64 24. If you leave this blank we will attempt to"
    echo "generate one for you using openssl. THIS WILL BE SHOWN IN PLAINTEXT."
    echo "Ex: mypackersecret8734"
    echo -n "> "
    read -r azure_client_secret
    if [ "$azure_client_secret" = "" ]; then
        if ! azure_client_secret=$(openssl rand -base64 24); then
            echo "Error generating secret"
            exit 1
        fi
        echo "Generated client_secret: $azure_client_secret"
    fi
}

askLocation() {
    az account list-locations
    echo ""
    echo "Choose which region your resource group and storage account will be created.  example: westus"
    echo -n "> "
    read -r location
}

createResourceGroup() {
    echo "==> Creating resource group"
    if az group create -n "$meta_name" -l "$location"; then
        azure_group_name=$meta_name
    else
        echo "Error creating resource group: $meta_name"
        return 1
    fi
}

createStorageAccount() {
    echo "==> Creating storage account"
    if az storage account create --name "$meta_name" --resource-group "$meta_name" --location "$location" --kind Storage; then
        azure_storage_name=$meta_name
    else
        echo "Error creating storage account: $meta_name"
        return 1
    fi
}

createApplication() {
    echo "==> Creating application"
    echo "==> Does application exist?"
    azure_client_id=$(az ad app list | jq -r '.[] | select(.displayName | contains("'$meta_name'")) ')
    
    if [ "$azure_client_id" != "" ]; then
        echo "==> application already exists, grab appId"
        if ! azure_client_id=$(az ad app list | jq -r '.[] | select(.displayName | contains("'$meta_name'")) .appId'); then
            echo "Error retrievig application id for application: $meta_name @ http://$meta_name"
            return 1
        fi
    else
        echo "==> application does not exist, create"
        if ! azure_client_id=$(az ad app create --display-name "$meta_name" --identifier-uris http://"$meta_name" --homepage http://"$meta_name" --password "$azure_client_secret" | jq -r .appId); then
            echo "Error creating application: $meta_name @ http://$meta_name"
            return 1
        fi
    fi

}

createServicePrincipal() {
    echo "==> Creating service principal"
    # az CLI 0.10.2 introduced a breaking change, where appId must be supplied with the -a switch
    # prior version accepted appId as the only parameter without a switch
    newer_syntax=false
    IFS='.' read -ra azureversionsemver <<< "$azureversion"
    if [ "${azureversionsemver[0]}" -ge 0 ] && [ "${azureversionsemver[1]}" -ge 10 ] && [ "${azureversionsemver[2]}" -ge 2 ]; then
        newer_syntax=true
    fi

    if [ "${newer_syntax}" = true ]; then
        if ! azure_object_id=$(az ad sp create --id "$azure_client_id" | jq -r .objectId); then
           echo "Error creating service principal (newer syntax): $azure_client_id"
           return 1
        else
            echo "$azure_object_id was selected."
        fi
    else
        if ! azure_object_id=$(az ad sp create --id "$azure_client_id" | jq -r .objectId); then
           echo "Error creating service principal: $azure_client_id"
           return 1
        else
           echo "$azure_object_id was selected."
        fi
    fi

}

createPermissions() {
    echo "==> Creating permissions"
    if az role assignment create --assignee "$azure_object_id" --role "Owner" --scope /subscriptions/"$azure_subscription_id"; then
    # We want to use this more conservative scope but it does not work with the
    # current implementation which uses temporary resource groups
    # az role assignment create --spn http://$meta_name -g $azure_group_name -o "API Management Service Contributor"
        echo "Error creating permissions for: http://$meta_name"
        return 1
    fi
}

showConfigs() {
    echo ""
    echo "Use the following configuration for your packer template:"
    echo ""
    echo "{"
    echo "      \"client_id\": \"$azure_client_id\","
    echo "      \"client_secret\": \"$azure_client_secret\","
    echo "      \"object_id\": \"$azure_object_id\","
    echo "      \"subscription_id\": \"$azure_subscription_id\","
    echo "      \"tenant_id\": \"$azure_tenant_id\","
    echo "      \"resource_group_name\": \"$azure_group_name\","
    echo "      \"storage_account\": \"$azure_storage_name\","
    echo "}"
    echo ""
}

doSleep() {
    local sleep_time=${PACKER_SLEEP_TIME-$create_sleep}
    echo ""
    echo "Sleeping for ${sleep_time} seconds to wait for resources to be "
    echo "created. If you get an error about a resource not existing, you can "
    echo "try increasing the amount of time we wait after creating resources "
    echo "by setting PACKER_SLEEP_TIME to something higher than the default."
    echo ""
    sleep "$sleep_time"
}

retryable() {
    n=0
    until [ $n -ge "$1" ]
    do
        $2 && return 0
        echo "$2 failed. Retrying..."
        n=$((n+1))
        doSleep
    done
    echo "$2 failed after $1 tries. Exiting."
    exit 1
}


setup() {
    requirements

    az login

    askSubscription
    askName
    askSecret
    askLocation

    # Some of the resources take a while to converge in the API. To make the
    # script more reliable we'll add a sleep after we create each resource.

    retryable 3 createResourceGroup
    retryable 3 createStorageAccount
    retryable 3 createApplication
    retryable 3 createServicePrincipal
    retryable 3 createPermissions

    showConfigs
}

case "$1" in
    requirements)
        requirements
        ;;
    setup)
        setup
        ;;
    *)
        showhelp
        ;;
esac
