#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
ROOT_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

DEST_USERNAME="$1"
DEST_PASSWORD="$2"
MIRROR_CONFIG="$3"

if [[ -z "${MIRROR_CONFIG}" ]]; then
  MIRROR_CONFIG="${ROOT_DIR}/mapping.txt"
fi

FILTER=""
if uname -a | grep -q Darwin; then
  FILTER="--override-os linux"
fi

echo "Loading mirror config from ${MIRROR_CONFIG}"
cat "${MIRROR_CONFIG}" | while read line; do
  echo "*** Processing line from config: $line"

  SOURCE=$(echo "$line" | sed -E "s~([^=]+)=(.*)~\1~g")
  DEST=$(echo "$line" | sed -E "s~([^=]+)=(.*)~\2~g")

  if echo $SOURCE | grep -q ":"; then
    TAGS=$(echo $SOURCE | sed -E "s/([^:]+):(.*)/\2/g")
    SOURCE=$(echo $SOURCE | sed -E "s/([^:]+):(.*)/\1/g")
    echo "Using source tag: ${TAGS}"
  else
    echo "+ Getting tags for ${SOURCE}"
    TAGS=$(skopeo inspect ${FILTER} "docker://${SOURCE}" | jq -r '.RepoTags[.RepoTags | length] |= . + "latest" | .RepoTags | .[]' | sort -Vu | tail -5)
  fi

  for tag in ${TAGS}; do
    echo "+ Mirroring tag docker://${SOURCE}:${tag} to docker://${DEST}:${tag}"
    skopeo copy ${FILTER} --dest-creds "${DEST_USERNAME}:${DEST_PASSWORD}" "docker://${SOURCE}:${tag}" "docker://${DEST}:${tag}"
  done
done