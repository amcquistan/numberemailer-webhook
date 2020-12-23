#!/bin/bash

if [ ! -f .env ]; then
  echo "!!! missing .env environment variables file"
  echo "see .env.example for list of environment variables required"
  exit 1
fi

source .env

if [[ -z $EXEC_ENV ]]; then 
  echo "!!! Missing environment variable EXEC_ENV"
  exit 1
fi

if [[ -z $DB_URL ]]; then
  echo "!!! Missing environment variable DB_URL"
  exit 1
fi

if [[ -z $BUCKET_NAME ]]; then
  echo "!!! Missing environment variable BUCKET_NAME"
  exit 1
fi

if [[ -z $AWS_PROFILE ]]; then
  echo "!!! Missing environment variable AWS_PROFILE"
  exit 1
fi

if [[ -z $AWS_REGION ]]; then
  echo "!!! Missing environment variable AWS_REGION"
  exit 1
fi

sam build

sam deploy --profile $AWS_PROFILE \
  --region $AWS_REGION \
  --parameter-overrides ExecEnv=$EXEC_ENV DBUrl=$DB_URL BucketName=$BUCKET_NAME \
  --guided

