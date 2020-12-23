#!/bin/bash

if [ ! -f .env.local ]; then
  echo "!!! missing .env environment variables file"
  echo "see .env.example for list of environment variables required"
  exit 1
fi

source .env.local

if [[ -z $EXEC_ENV ]]; then 
  echo "!!! Missing environment variable EXEC_ENV"
  exit 1
fi

if [[ -z $DB_URL ]]; then
  echo "!!! Missing environment variable"
  exit 1
fi

if [[ -z $BUCKET_NAME ]]; then
  echo "!!! Missing environment variable"
  exit 1
fi

sam build --use-container

set -x

sam local start-api \
  --parameter-overrides ExecEnv=$EXEC_ENV DBUrl=$DB_URL BucketName=$BUCKET_NAME
