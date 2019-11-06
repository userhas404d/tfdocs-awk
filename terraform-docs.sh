#!/bin/bash

set -e
set -u

# https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself/246128#246128
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

test -d "$2" || ( echo "$2 must be a directory"; exit 1 )
MODULE="$( cd "$2" >/dev/null 2>&1 && pwd )"

command -v awk > /dev/null 2>&1 || ( echo "awk not available"; exit 1)
command -v terraform > /dev/null 2>&1 || ( echo "terraform not available"; exit 1)
command -v terraform-docs > /dev/null 2>&1 || ( echo "terraform-docs not available"; exit 1)

if [[ "$(terraform version | head -1)" =~ 0\.12 ]]; then
    pushd "$MODULE" >/dev/null 2>&1 || ( echo "Unable to navigate to $MODULE"; exit 1)
    TMP_FILE="$(mktemp /tmp/terraform-docs-XXXXXXXXXX)"
    # shellcheck disable=SC2035
    awk -f "$DIR/terraform-docs.awk" *.tf > "${TMP_FILE}"
    terraform-docs "$1" "${TMP_FILE}"
    rm -f "${TMP_FILE}"
    popd >/dev/null 2>&1 || ( echo "Unable to return to source directory"; exit 1)
else
    terraform-docs "$1" "$2"
fi
