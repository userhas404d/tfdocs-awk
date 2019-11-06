#!/usr/bin/env bash

set -e
set -u

LINT=
GENERATE=

while getopts :gl opt
do
    case "${opt}" in
        l)
            LINT=1
            ;;
        g)
            GENERATE=1
            ;;
        \?)
            echo "ERROR: unknown parameter \"$OPTARG\"" 1>&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

# create an array of all unique directories containing .tf files
mapfile -t directories < <(find . -name '*.tf' -exec dirname {} \; | sort -u)

for dir in "${directories[@]}"
do
    docs_dir="${dir}/_docs"

    source_doc=$docs_dir/MAIN.md
    target_doc="${dir}/README.md"

    # check for _docs folder
    if [[ -d "$docs_dir" ]]; then

        if ! test -f "$source_doc"; then 
            echo "ERROR: $source_doc is missing" 1>&2; exit 1
        else

        # validate that the source terraform is valid before proceeding
        terraform-docs.sh markdown "${dir}" > /dev/null 2>&1 || exit 1

            # generate the tf documentation
            if [[ -n "$GENERATE" ]]; then
                echo "Generating docs for: ${dir}" 1>&2
                cat "$source_doc" <(echo) <(terraform-docs.sh markdown "${dir}") > "$target_doc"
            fi

            # lint the tf documentation
            if [[ -n "$LINT" ]]; then
                echo "Linting docs for: ${dir}" 1>&2
                diff "$target_doc" <(cat "$source_doc" <(echo) <(terraform-docs.sh markdown "${dir}"))
            fi

        fi

    fi
done