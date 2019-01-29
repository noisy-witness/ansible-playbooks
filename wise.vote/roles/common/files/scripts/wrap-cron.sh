#!/usr/bin/env bash

CRON_LOG_FILE="/var/log/wise-cron.log"

TIME_START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "" >> "${CRON_LOG_FILE}"
echo "[${TIME_START}] start ${CRON_JOB_NAME}"
echo "[${TIME_START}] start ${CRON_JOB_NAME}" >> "${CRON_LOG_FILE}"

eval "$@" >> "${CRON_LOG_FILE}" 2>&1

TIME_FINISH=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "[${TIME_FINISH}] finish ${CRON_JOB_NAME}"
echo "[${TIME_FINISH}] finish ${CRON_JOB_NAME}" >> "${CRON_LOG_FILE}"

echo "Done"
