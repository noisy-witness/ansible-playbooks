#!/usr/bin/env bash
set -e # fail on first error
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.." # parent dir
cd "${DIR}"

ansible-playbook -i wise.vote/staging.yml \
    --extra-vars "@~/p/ansible/staging.yml" \
    --vault-id jblew_staging@prompt \
    --vault-id generic@prompt -vv wise.vote/wise.vote.yml \
    $@