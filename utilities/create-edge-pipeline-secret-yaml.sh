#!/bin/bash
# --------------------------------------------------------------------------------------------------------
# Name : Create Edge Access Secret for use in CI/CD Pipeline in Development Cluster
#
# Log into Edge Cluster and run this script
# The script expects two arguments, Org ID and API
#
# Once Secret has been create apply the secret to you development project/namespace
#
# Author : Matthew Perrins mjperrin@us.ibm.com, Steve.Cotugno@us.ibm.com
# Update:  Updated to support EAM V4.2.  
#
# For access to private registry (OCP_REG_HOST) see https://www.ibm.com/docs/en/edge-computing/4.2?topic=reading-using-private-container-registry
# --------------------------------------------------------------------------------------------------------
#
# input validation

echo -e "\n${0} will create an edge-access secret in the EAM HUB OCP Cluster for the Cloud Native toolkit pipeline.  '\n"
echo -e "\n Before running ${0}, login to your EAM HUB OCP Cluster and select your OCP which your pipeline is run.'\n"

if [ -z "$2" ]; then
    echo -e "\n Missing agument.  Usage:  '${0} <Org ID> <API KEY> '\n"
    exit 1
fi

export HZN_ORG_ID=$1
export EDGE_APIKEY=$2

# Extract the Core meta data for
export HZN_EXCHANGE_USER_AUTH=iamapikey:${EDGE_APIKEY}
export MGM_HUB_INGRESS=$(oc get cm management-ingress-ibmcloud-cluster-info -n ibm-edge -o jsonpath='{.data.cluster_ca_domain}')
export HZN_EXCHANGE_URL=https://${MGM_HUB_INGRESS}/edge-exchange/v1
export HZN_FSS_CSSURL=https://${MGM_HUB_INGRESS}/edge-css/
export OCP_REG_HOST=`oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}'`

# Extract the Certificate Authority Certificate
oc get secret management-ingress-ibmcloud-cluster-ca-cert -n ibm-common-services  -o  jsonpath="{.data['ca\.crt']}" | base64 --decode > ./icp-ca.crt
oc serviceaccounts get-token pipeline > ./get-token-ca.crt

# Create the Secret
oc create secret generic edge-access \
  --from-literal=HZN_ORG_ID=$HZN_ORG_ID \
  --from-literal=HZN_EXCHANGE_USER_AUTH=$HZN_EXCHANGE_USER_AUTH \
  --from-literal=HZN_EXCHANGE_URL=$HZN_EXCHANGE_URL \
  --from-literal=HZN_FSS_CSSURL=$HZN_FSS_CSSURL \
  --from-literal=OCP_REG_HOST=$OCP_REG_HOST \
  --from-literal=OCP_REG_USER="pipeline" \
  --from-file=OCP_REG_TOKEN=./get-token-ca.crt \
  --from-file=HZN_CERTIFICATE=./icp-ca.crt \
  -o yaml --dry-run | \
oc label -f - --dry-run --local -o yaml --local \
  group=catalyst-tools \
  grouping=garage-cloud-native-toolkit  > edge-access-secret.yaml

echo "Completed creating the edge-access-security.yaml ..."