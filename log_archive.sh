#!/bin/bash 

set -euo pipefail

source ./config.conf 

mkdir -p "$ARCHIVE_DIR" 
mkdir -p "$REPORT_DIR"

CURRENT_TIME=$(date +"%Y%m%d_%H%M%S")

HOST=$(hostname)

ARCHIVE_NAME="Archive_${CURRENT_TIME}.tar.gz"

echo -e " =======Archive started on $CURRENT_TIME=========" >> "$ARCHIVE_REPORT_FILE"

ERROR=$(tar -czf "$ARCHIVE_DIR/$ARCHIVE_NAME" -C "$BACKUP_DIR" . 2>&1)
STATUS=$?

if [ $STATUS -eq 0 ]; then
    echo -e " Status : OK" >> "$ARCHIVE_REPORT_FILE"
    find "$ARCHIVE_DIR" -name "*.gz" -mtime +"$LOG_RETENTION_DAYS" -delete

else
    Subject=" !!! Archive failed !!! On Host: $HOST"
    Body="
        Archive failed on $CURRENT_TIME
        Please check the below error:
        $ERROR
        "
    echo "$Body" | mail -s "$Subject" "$ADMIN_MAIL"
    echo -e "Status : failed \n 
        Mail sent to Admin: $ADMIN_MAIL\n\n" >> "$ARCHIVE_REPORT_FILE"
fi

echo -e "=============================================================\n"
