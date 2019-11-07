#!/bin/bash

set -x

if [ "$1" == "nodejs-typescript" ]; then
  PIPELINE="nodejs-pipeline"
  GIT="nodejs-typescript-git"
  IMAGE="nodejs-typescript-image"
elif [ "$1" == "nodejs-react" ]; then
  PIPELINE="nodejs-pipeline"
  GIT="nodejs-react-git"
  IMAGE="nodejs-react-image"
elif [ "$1" == "nodejs-angular" ]; then
  PIPELINE="nodejs-pipeline"
  GIT="nodejs-angular-git"
  IMAGE="nodejs-angular-image"
elif [ "$1" == "java-spring" ]; then
  PIPELINE="java-gradle-pipeline"
  GIT="java-spring-git"
  IMAGE="java-spring-image"
else 
  echo "Usage: $0 [nodesjs-typescript | nodejs-react | nodejs-angular |java-spring]"
  exit 1
fi


tkn pipeline start \
  ${PIPELINE} \
  -r git-source=${GIT} \
  -r docker-image=${IMAGE} \
  -s pipeline

