#!/bin/bash

source ./config.conf

echo "===== Disk Usage Report $(date) =====" > "$REPORT_FILE"

# Skip the header (NR>1)
df -P | awk 'NR>1 {gsub("%","",$5); print $1, $5}' |
while read -r mount usage
do
    if [ "$mount" = "/tmp" ]; then
        echo -e " Mount      : $mount \n------" >> "$REPORT_FILE"
        if [ "$usage" -gt "$THRESHOLD" ]; then
            echo "[WARNING] /tmp usage is ${usage}%. Cleaning temporary files..." \
              >> "$REPORT_FILE"

            # Remove files older than 1 day (safer than deleting everything)
            find /tmp -mindepth 1 -mtime +1 -delete

            echo "/tmp cleanup completed." >> "$REPORT_FILE"
        else
            echo -e " status      : OK \n" >> "$REPORT_FILE"
        fi
    else
        echo -e "Mount Point : $mount \n------" >> "$REPORT_FILE"
        echo "Usage       : ${usage}%" >> "$REPORT_FILE"

        if [ "$usage" -gt "$THRESHOLD" ]; then
          
            # Send email notification
            SUBJECT="!!!High Alert!!! Disk Usage Alert on $(hostname)"
            BODY="Warning!
                Filesystem: $mount
                Current Usage: ${usage}%
                Threshold: ${THRESHOLD}%

                Please investigate and free up disk space."

            echo "$BODY" | mail -s "$SUBJECT" "$ADMIN_MAIL"

            echo -e "Status      : WARNING - Above threshold \nMail sent for Admin: $ADMIN_MAIL" >> "$REPORT_FILE"
        else
            echo "Status      : OK" >> "$REPORT_FILE"
        fi
    fi
done
echo "-----------------------------------" >> "$REPORT_FILE"