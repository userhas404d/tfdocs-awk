#!/bin/bash

command -v awk > /dev/null 2>&1 || ( echo "awk not available"; exit 1)
command -v terraform > /dev/null 2>&1 || ( echo "terraform not available"; exit 1)
command -v terraform-docs > /dev/null 2>&1 || ( echo "terraform-docs not available"; exit 1)

if [[ "$(terraform version | head -1)" =~ 0\.12 ]]; then
    TMP_FILE="$(mktemp /tmp/terraform-docs-XXXXXXXXXX)"
    # shellcheck disable=SC2035
    awk -f scripts/terraform-docs.awk *.tf > "${TMP_FILE}"
    terraform-docs "$1" "${TMP_FILE}"
    rm -f "${TMP_FILE}"
else
    terraform-docs "$1" "$2"
fi
