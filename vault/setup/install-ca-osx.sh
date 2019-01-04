#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
set -e # fail on first error

sudo security add-trusted-cert \
    -k /Library/Keychains/System.keychain \
    -d CA.crt