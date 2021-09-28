if [ -z $IBM_CLOUD_APIKEY ]; then
    echo "Please specify an IBM_CLOUD_APIKEY environment variable"
    exit 1
fi

if [ -z $VAULT_URL ]; then
    echo "Please specify an VAULT_URL environment variable that points to your vault instance."
    echo "If you are using IBM Key Protect this will be in the format https://<region>.kms.cloud.ibm.com."
    echo "If you are using IBM Hyper Protect this will be in the format https://api.<region>.hs-crypto.cloud.ibm.com:<port>, and the full URL and port can be accessed from your HPCS instance's 'Overview' page."
    exit 1
fi

if [ -z $VAULT_INSTANCE_ID ]; then
    echo "Please specify an VAULT_INSTANCE_ID environment variable"
    echo "This is the unique ID or the Key Protect of HPCS instance."
    exit 1
fi

export PRIVATE_KEY_NAME="portieris-image-signing-private-key"
export PRIVATE_KEY_DESCRIPTION="Private key for signing docker images"
export PUBLIC_KEY_NAME="portieris-image-signing-public-key"
export PUBLIC_KEY_DESCRIPTION="Public key for signing docker images"

oc project
if [ $? != 0 ]; then
    echo "Please log into the OpenShift cluster with the 'oc login' command."
    exit 1
fi

if ! command -v gpg &> /dev/null
then
    echo "gpg could not be found.  Please install gpg according to https://gnupg.org/download/"
    exit 1
fi



printf "\n\n"
echo "More details about image signing at https://cloud.ibm.com/docs/Registry?topic=Registry-registry_trustedcontent"
echo "More details about creating keys with gpg at https://www.redhat.com/sysadmin/creating-gpg-keypairs"
printf "\n\n"
echo "Generating a new image signing key using gpg."
echo "You will be prompted for additional input..."
printf "\n\n"


output=$(gpg --default-new-key-algo rsa4096 --generate-key)
printf "\n-----\n${output}\n-----\n\n"

KEY_FINGERPRINT=$(echo "${output}" | sed -n '2p' | tr -d ' ')
echo "Exporting private key to vault"

ENCODED_PRIVATE_KEY=$(gpg --export-secret-key $KEY_FINGERPRINT | base64) 



# Get IAM access token for subsequent requests
curl -s -o token.txt \
    -X POST "https://iam.cloud.ibm.com/identity/token" \
    --header "Content-Type: application/x-www-form-urlencoded" \
    --header "Accept: application/json"  \
    --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
    --data-urlencode "apikey=${IBM_CLOUD_APIKEY}"

IAM_TOKEN=$(jq ".access_token" -r token.txt)
rm -rf token.txt



# save the private key in the vault
curl -s -o payload \
    -X POST "$VAULT_URL/api/v2/keys" \
    -H "authorization: Bearer $IAM_TOKEN" \
    -H "bluemix-instance: $VAULT_INSTANCE_ID"  \
    -H "content-type: application/vnd.ibm.kms.key+json" \
    -d "{
        \"metadata\": {
            \"collectionType\": \"application/vnd.ibm.kms.key+json\",
            \"collectionTotal\": 1
        },
        \"resources\": [
            {
                \"type\": \"application/vnd.ibm.kms.key+json\",
                \"name\": \"$PRIVATE_KEY_NAME\",
                \"aliases\": [],
                \"description\": \"$PRIVATE_KEY_DESCRIPTION\",
                \"payload\": \"$ENCODED_PRIVATE_KEY\",
                \"extractable\": true
            }
        ]
    }"
VAULT_PRIVATE_KEY_ID=$(jq ".resources[0].id" -r payload)
rm -rf payload
echo "$PRIVATE_KEY_NAME saved to vault"



# save public key in a cluster secret

echo "Exporting public key as a cluster secret"
gpg --export --armour $KEY_FINGERPRINT > key.pubkey
oc delete secret $PUBLIC_KEY_NAME 
oc create secret generic $PUBLIC_KEY_NAME --from-file=key=key.pubkey
rm -rf key.pubkey


# save public key in the vault
echo "Exporting public key to vault"
ENCODED_PUBLIC_KEY=$(gpg --export $KEY_FINGERPRINT | base64) 

curl -sX POST "$VAULT_URL/api/v2/keys" \
    -H "authorization: Bearer $IAM_TOKEN" \
    -H "bluemix-instance: $VAULT_INSTANCE_ID"  \
    -H "content-type: application/vnd.ibm.kms.key+json" \
    -d "{
        \"metadata\": {
            \"collectionType\": \"application/vnd.ibm.kms.key+json\",
            \"collectionTotal\": 1
        },
        \"resources\": [
            {
                \"type\": \"application/vnd.ibm.kms.key+json\",
                \"name\": \"$PUBLIC_KEY_NAME\",
                \"aliases\": [],
                \"description\": \"$PUBLIC_KEY_DESCRIPTION\",
                \"payload\": \"$ENCODED_PUBLIC_KEY\",
                \"extractable\": true
            }
        ]
    }"
printf "\n$PUBLIC_KEY_NAME saved to vault\n"





# apply porteris policies:


cat > "portieris-signed-images.yml" << EOL
apiVersion: portieris.cloud.ibm.com/v1
kind: ClusterImagePolicy
metadata:
  name: portieris-default-cluster-image-policy
spec:
   repositories:
    - name: "private.us.icr.io/your-registry-namespace/your-app"
      policy:
        mutateImage: false
        simple:
          requirements:
          - type: "signedBy"
            keySecret: ${PUBLIC_KEY_NAME}
EOL
oc apply -f portieris-signed-images.yml
rm -rf portieris-signed-images.yml




# create configmap to be used when signing the with the build-tag-push tekton task

cat > "portieris-secrets.yml" << EOL
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: portieris-keys
data:
  vault-url: "$(echo -n $VAULT_URL | base64)"
  vault-instance-id: "$(echo -n $VAULT_INSTANCE_ID | base64)"
  vault-key-id: "$(echo -n $VAULT_PRIVATE_KEY_ID | base64)"
  portieris-signature-fingerprint: "$(echo -n $KEY_FINGERPRINT | base64)"
  
EOL
oc apply -f portieris-secrets.yml
rm -rf portieris-secrets.yml


