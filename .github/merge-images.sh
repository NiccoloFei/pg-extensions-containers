#!/usr/bin/env bash
set -eEuo pipefail

ARCHS="amd64 arm64"
TEMP_DIR="$(mktemp -d)"
trap 'rm -fr ${TEMP_DIR}' EXIT

# Collect all tags
for ARCH in $ARCHS; do
    platform_suffix="-$ARCH" docker buildx bake --print 2> /dev/null \
      | jq -r '.target[].tags[]' >> "${TEMP_DIR}/all-tags.txt"
done

# Extract unique (extension + version + distro) identifiers
sed 's/-[^-]*$//' "${TEMP_DIR}/all-tags.txt" | sort -u | uniq > "${TEMP_DIR}/base-tags.txt"

# Merge per base tag
while read BASE_TAG; do
  FULL_TAGS=$(grep "$BASE_TAG" "${TEMP_DIR}/all-tags.txt" | xargs)
  echo "Merging: $FULL_TAGS → $BASE_TAG"

  docker buildx imagetools create \
    --tag "${BASE_TAG}" \
    $FULL_TAGS
done < "${TEMP_DIR}/base-tags.txt"
