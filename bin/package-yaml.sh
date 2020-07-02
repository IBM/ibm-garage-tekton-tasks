#!/usr/bin/env bash

VERSION_NUMBER="$1"

if [[ -z "${VERSION_NUMBER}" ]]; then
  echo "The version number is required as the first parameter. E.g. $0 1.0.0"
  exit 1
fi

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
ROOT_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

DIST_DIR="${ROOT_DIR}/dist"

mkdir -p "${DIST_DIR}"

RESOURCE_YAML="${DIST_DIR}/release.yaml"

echo -n "" > "${RESOURCE_YAML}"

# remove leading 'v', if present
VERSION_NUMBER=$(echo "${VERSION_NUMBER}" | sed -E "s/v*(.*)/\1/g")
# replace dots with dashes and prefix 'v' for yaml version
YAML_VERSION=$(echo "${VERSION_NUMBER}" | sed -E "s/[.]/-/g" | sed -E "s/(.*)/v\1/g")

find "${ROOT_DIR}/tasks" -name "*.yaml" | while read -r file; do
  cat "${file}" | \
    perl -0777p -e "s/(metadata:\n +name: [a-z-]+)/\1-${YAML_VERSION}/mg" | \
    perl -0777p -e "s/version: 0.0.0/version: ${VERSION_NUMBER}/g" >> "${RESOURCE_YAML}"
  echo "---" >> "${RESOURCE_YAML}"
done
find "${ROOT_DIR}/pipelines" -name "*.yaml" | while read -r file; do
  cat "$file" | \
    perl -0777p -e "s/(metadata:\n +name: [a-z-]+)/\1-${YAML_VERSION}/mg" | \
    perl -0777p -e "s/version: 0.0.0/version: ${VERSION_NUMBER}/g" | \
    perl -0777p -e "s/(taskRef:\n +name: [a-z-]+)/\1-${YAML_VERSION}/mg" >> "${RESOURCE_YAML}"
  echo "---" >> "${RESOURCE_YAML}"
done
