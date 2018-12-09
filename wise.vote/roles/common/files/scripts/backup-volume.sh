#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${SOURCE_VOLUME}" ]; then
    echo "SOURCE_VOLUME env is not set"
    exit 1
fi

if [ -z "${TARGET_BACKUP_BZ2_FILE}" ]; then
    echo "TARGET_BACKUP_BZ2_FILE env is not set"
    exit 1
fi

get_abs_filename() {
  # https://stackoverflow.com/a/21188136/761265
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

TARGET_DIR=$(dirname "${TARGET_BACKUP_BZ2_FILE}")
TARGET_DIR_ABSOLUTE=$(get_abs_filename "${TARGET_DIR}")
TARGET_FILENAME=$(basename "${TARGET_BACKUP_BZ2_FILE}")

docker run --rm -v "${SOURCE_VOLUME}:/volume" -v "${TARGET_DIR_ABSOLUTE}:/backup" alpine \
    tar -cjf "/backup/${TARGET_FILENAME}" -C /volume ./
