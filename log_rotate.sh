#!/bin/bash 

set -euo pipefail

source ./config.conf 

mkdir -p "$BACKUP_DIR" 
mkdir -p "$REPORT_DIR"

HOST=$(hostname)

if [ ! -f "$STATE_FILE" ]; then
    date +"%Y%m%d_%H%M%S" > "$STATE_FILE"
fi

LAST_ROTATION_TIME=$(cat "$STATE_FILE")
CURRENT_TIME=$(date +"%Y%m%d_%H%M%S")

#ARCHIVE_NAME="logs_${LAST_ROTATION}_to_${CURRENT_TIME}.tar.gz"

#ERROR=$(tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" -C "$LOG_DIR" . 2>&1)

echo -e " Log rotatation from $LAST_ROTATION_TIME to $CURRENT_TIME Started \n--------" >> "$LOG_REPORT_FILE"

ERROR=$(mv "$LOG_DIR"/* "$BACKUP_DIR" 2>&1)
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo " Status : Successful" >> "$LOG_REPORT_FILE"
   
    echo "$CURRENT_TIME" > "$STATE_FILE"
else
    Subject=" !!! Log Rotation failed !!! On Host: $HOST"
    Body="
        Log rotatation from $LAST_ROTATION to $CURRENT_TIME failed
        Please check the below error:
        $ERROR
        "
    echo "$Body" | mail -s "$Subject" "$ADMIN_MAIL"
    echo -e "Status : failed \n 
        Mail sent to Admin: $ADMIN_MAIL" >> "$LOG_REPORT_FILE"
fi

echo -e "=======================================\n"
