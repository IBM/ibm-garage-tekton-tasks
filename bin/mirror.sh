#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname $0); pwd -P)
ROOT_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

MIRROR_CONFIG="$1"
AUTH_FILE="$2"

if [[ -z "${MIRROR_CONFIG}" ]]; then
  MIRROR_CONFIG="${ROOT_DIR}/mapping.txt"
fi

FILTER=""
if uname -a | grep -q Darwin; then
  FILTER="--override-os linux"
fi

if [[ -n "${AUTH_FILE}" ]]; then
  AUTH_FILE_ARG="--authfile ${AUTH_FILE}"
fi

echo "Loading mirror config from ${MIRROR_CONFIG}"
cat "${MIRROR_CONFIG}" | while read line; do
  if [[ "${line}" =~ ^# ]]; then
    continue
  fi
  
  echo "*** Processing line from config: $line"

  SOURCE=$(echo "$line" | sed -E "s~([^=]+)=(.*)~\1~g")
  DEST=$(echo "$line" | sed -E "s~([^=]+)=(.*)~\2~g")

  echo "+ Mirroring tag docker://${SOURCE}:${tag} to docker://${DEST}:${tag}"
  skopeo sync ${FILTER} ${AUTH_FILE_ARG}  --src docker --dest docker "${SOURCE}" "${DEST}"
done
