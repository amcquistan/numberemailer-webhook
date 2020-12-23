#!/bin/bash

# exit when any command fails
set -eE -o functrace

if [[ -f ./create-bucket.sh ]]; then
  cd ..
fi

if [[ ! -d ./rest_api ]]; then 
  printf "Expecting to be ran from s3 or project base directory. Exiting!\n"
  exit 1
fi

if [[ $1 == 'local' ]]; then

  if [[ ! -f .env.local ]]; then
    printf "No .env.local environment variable file found.\n"
    printf "See .env.example for details.\n"
    exit 1
  else
    source .env.local
  fi

elif [[ $1 == 'prod' ]]; then
  if [[ ! -f .env ]]; then
    printf "No .env environment variable file found.\n"
    printf "See .env.example for details.\n"
    exit 1
  else
    source .env
  fi
else
  printf "Must pass argument of local or prod"
  exit 1
fi

if [[ -z $BUCKET_NAME  ]]; then
  printf "Environment variable BUCKET_NAME missing\n"
  exit 1
fi

if [[ -z $AWS_PROFILE ]]; then
  printf "Environment variable AWS_PROFILE missing\n"
  exit 1
fi

if [[ -z $AWS_REGION ]]; then
  printf "Environment variable AWS_REGION missing\n"
  exit 1
fi

if [[ -z $LAMBDA_IAM_ROLE_ARN ]]; then
  printf "Environment variable LAMBDA_IAM_ROLE_ARN missing\n"
  exit 1
fi

POLICY="{\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"$LAMBDA_IAM_ROLE_ARN\"},\"Action\":[\"s3:GetObject\",\"s3:PutObject\"],\"Resource\":\"arn:aws:s3:::$BUCKET_NAME/*\"}]}"

# POLICY=$(echo $POLICY)
# echo $POLICY

set -x

aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $AWS_REGION \
  --create-bucket-configuration LocationConstraint=$AWS_REGION \
  --profile $AWS_PROFILE


aws s3api put-bucket-policy \
  --bucket $BUCKET_NAME \
  --policy $POLICY \
  --profile $AWS_PROFILE

