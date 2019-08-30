#!/usr/bin/env bash

LINT=
GENERATE=

while getopts :lL:gG: opt
do
    case "${opt}" in
        l)
            LINT=1
            ;;
        g)
            GENERATE=1
            ;;
        \?)
            echo "ERROR: unknown parameter \"$OPTARG\""
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

IFS=$'\n'
# create an array of all unique directories containing .tf files 
IFS=$'\n' directories=($(find . -name '*.tf' | xargs -I % sh -c 'dirname %' | sort -u))

for dir in "${directories[@]}"
do
    docs_dir="${dir}/_docs"

    source_doc=$docs_dir/MAIN.md
    target_doc="${dir}/README.md"

    # check for _docs folder
    if [[ -d "$docs_dir" ]]; then

        if ! test -f $source_doc; then 
            echo "ERROR: $source_doc is missing"; exit 1
        else

            # generate the tf documentation
            if [[ -n "$GENERATE" ]]; then
                echo "Generating docs for: ${dir}"
                cat $source_doc <(echo) <(scripts/terraform-docs.sh markdown "${dir}") > $target_doc
            fi

            # lint the tf documentation
            if [[ -n "$LINT" ]]; then
                echo "Linting docs for: ${dir}"
                diff $target_doc <(cat $source_doc <(echo) <(scripts/terraform-docs.sh markdown ${dir}))
            fi

        fi

    fi
done