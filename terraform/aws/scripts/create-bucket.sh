#!/bin/bash
set -e

while getopts n:r:a: option
do
 case "${option}"
 in
 n) NAME=${OPTARG};;
 r) REGION=${OPTARG};;
 a) ACL=$OPTARG;;
 esac
done
printf $NAME 
printf "\n"
printf $REGION
printf "\n"
printf $ACL

# We assume you have the AWS CLI installed.  Create S3 Bucket with specific parameters
aws s3api create-bucket --bucket $NAME --region $REGION --acl $ACL --create-bucket-configuration LocationConstraint=$REGION

# Enable S3 Bucker Versioning
aws s3api put-bucket-versioning --bucket $NAME --versioning-configuration Status=Enabled 

# Create AWS DynamoDB Table with Key for locking
aws dynamodb create-table --table-name terraform-lock --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5