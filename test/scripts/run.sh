#!/bin/bash


if [ "$1" == "nodejs-typescript" ]; then
  PIPELINE="igc-nodejs"
  GIT="nodejs-typescript-git"
  IMAGE="nodejs-typescript-image"
elif [ "$1" == "nodejs-react" ]; then
  PIPELINE="igc-nodejs"
  GIT="nodejs-react-git"
  IMAGE="nodejs-react-image"
elif [ "$1" == "nodejs-angular" ]; then
  PIPELINE="igc-nodejs"
  GIT="nodejs-angular-git"
  IMAGE="nodejs-angular-image"
elif [ "$1" == "java-spring" ]; then
  PIPELINE="igc-java-gradle"
  GIT="java-spring-git"
  IMAGE="java-spring-image"
else 
  echo "Usage: $0 [nodesjs-typescript | nodejs-react | nodejs-angular | java-spring]"
  exit 1
fi


tkn pipeline start \
  ${PIPELINE} \
  -r git-source=${GIT} \
  -r docker-image=${IMAGE} \
  -s pipeline

