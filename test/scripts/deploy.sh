#!/bin/bash

set -x

oc delete tasks --all
oc delete pipelines --all
sleep 3
oc create -f tasks/
oc create -f pipelines/

