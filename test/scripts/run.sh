#!/bin/bash

GIT_ORG=${GIT_ORG:-https://github.com/<replace>}

if [ "$1" == "go-gin" ]; then
  PIPELINE="ibm-golang"
  GIT_REPO="template-go-gin"
  SCAN="true"
elif [ "$1" == "nodejs-typescript" ]; then
  PIPELINE="ibm-nodejs"
  GIT_REPO="template-node-typescript"
  SCAN="true"
elif [ "$1" == "nodejs-react" ]; then
  PIPELINE="ibm-nodejs"
  GIT_REPO="template-node-react"
  SCAN="true"
elif [ "$1" == "nodejs-angular" ]; then
  PIPELINE="ibm-nodejs"
  GIT_REPO="template-node-angular"
  SCAN="true"
elif [ "$1" == "nodejs-graphql" ]; then
  PIPELINE="ibm-nodejs"
  GIT_REPO="template-node-angular"
  SCAN="true"
elif [ "$1" == "java-spring" ]; then
  PIPELINE="ibm-java-gradle"
  GIT_REPO="template-java-spring"
  SCAN="true"
else
  echo "Usage: $0 [go-gin | nodejs-typescript | nodejs-react | nodejs-angular | nodejs-graphql | java-spring]"
  exit 1
fi
set -x

tkn pipeline start \
  ${PIPELINE} \
  -p git-url=${GIT_ORG}/${GIT_REPO} \
  -p scan-image=${SCAN} \
  -s pipeline \
  --showlog