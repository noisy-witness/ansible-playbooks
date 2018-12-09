#!/usr/bin/env bash

CRON_LOG_FILE="/var/log/wise-cron.log"

TIME_START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "" >> "${CRON_LOG_FILE}"
echo "Cron job start ${JOB_NAME} at ${TIME_START}"
echo "Cron job start ${JOB_NAME} at ${TIME_START}" >> "${CRON_LOG_FILE}"

eval "$@" 2>&1 >> "${CRON_LOG_FILE}"

TIME_FINISH=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "Cron job finish ${JOB_NAME} at ${TIME_FINISH}"
echo "Cron job finish ${JOB_NAME} at ${TIME_FINISH}" >> "${CRON_LOG_FILE}"

echo "Done"
