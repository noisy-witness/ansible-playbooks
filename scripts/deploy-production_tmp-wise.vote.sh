#!/usr/bin/env bash
set -e # fail on first error
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.." # parent dir
cd "${DIR}"

ANSIBLE_CONFIG="${DIR}/../ansible.cfg" ansible-playbook -i wise.vote/production_tmp.yml \
    --extra-vars "@~/p/ansible/mort.yml" \
    --vault-id jblew_production@prompt \
    --vault-id generic@prompt -vvv wise.vote/wise.vote.yml \
    $@