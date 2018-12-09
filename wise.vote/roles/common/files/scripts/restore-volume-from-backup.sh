#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${TARGET_VOLUME}" ]; then
    echo "TARGET_VOLUME env is not set"
    exit 1
fi

if [ -z "${SOURCE_BACKUP_BZ2_FILE}" ]; then
    echo "SOURCE_BACKUP_BZ2_FILE env is not set"
    exit 1
fi

get_abs_filename() {
  # https://stackoverflow.com/a/21188136/761265
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

SOURCE_DIR=$(dirname "${SOURCE_BACKUP_BZ2_FILE}")
SOURCE_DIR_ABSOLUTE=$(get_abs_filename "${SOURCE_DIR}")
SOURCE_FILENAME=$(basename "${SOURCE_BACKUP_BZ2_FILE}")

docker run --rm -v "${TARGET_VOLUME}:/volume" -v "${SOURCE_DIR_ABSOLUTE}:/backup" alpine \
    sh -c "rm -rf /volume/* /volume/..?* /volume/.[!.]* ; tar -C /volume/ -xjf /backup/${SOURCE_FILENAME}"
