#!/bin/bash

set -euo pipefail

source ./config.conf

ALERT_MESSAGES=""

HOST=$(hostname)
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

mkdir -p "$REPORT_DIR"

echo "===== Health Check Report $TIMESTAMP =====" > "$HEALTH_REPORT_FILE"

echo "--------------Disk Usage Report-------------------"

# Skip the header (NR>1)
df -P | awk 'NR>1 {gsub("%","",$5); print $1, $5}' |
while read -r mount usage
do
    if [ "$mount" = "/tmp" ]; then
        echo -e " Mount      : $mount \n------" >> "$HEALTH_REPORT_FILE"
        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
            echo "[WARNING] /tmp usage is ${usage}%. Cleaning temporary files..." \
              >> "$HEALTH_REPORT_FILE"

            # Remove files older than 1 day (safer than deleting everything)
            find /tmp -mindepth 1 -mtime +7 -delete

            echo "/tmp cleanup completed." >> "$HEALTH_REPORT_FILE"
        else
            echo -e " status      : OK \n" >> "$HEALTH_REPORT_FILE"
        fi
    else
        echo -e "Mount Point : $mount \n------" >> "$HEALTH_REPORT_FILE"
        echo "Usage       : ${usage}%" >> "$HEALTH_REPORT_FILE"

        if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
          
            ALERT_MESSAGES+="Warning!
Filesystem: $mount
Current Usage: ${usage}%
Threshold: ${DISK_THRESHOLD}%
Please investigate and free up disk space.
            
"
            echo -e "Status : UnHealthy\n" >> "$HEALTH_REPORT_FILE"
        else
            echo -e "Status      : OK\n" >> "$HEALTH_REPORT_FILE"
        fi
    fi
done
echo "-----------------------------------" >> "$HEALTH_REPORT_FILE"

echo "---------------Memory and CPU Usage Report------------------"

# CPU Usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print int($2 + $4)}')

# Memory Usage
MEM_USAGE=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')

# CPU Threshold Check
if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
    ALERT_MESSAGES+="
[$TIMESTAMP]
High CPU Usage Detected
Host      : $HOST
CPU Usage : ${CPU_USAGE}%
Threshold : ${CPU_THRESHOLD}%

"
    echo -e "CPU Status : $CPU_USAGE :Unhealthy\n" >> "$HEALTH_REPORT_FILE"
else
    echo -e " CPU Status : $CPU_USAGE : OK\n" >> "$HEALTH_REPORT_FILE"
fi

# Memory Threshold Check
if [ "$MEM_USAGE" -gt "$MEM_THRESHOLD" ]; then
    ALERT_MESSAGES+="
[$TIMESTAMP]
High Memory Usage Detected
Host         : $HOST
Memory Usage : ${MEM_USAGE}%
Threshold    : ${MEM_THRESHOLD}%

"
    echo -e "Memory Status : $MEM_USAGE : Unhealthy\n" >> "$HEALTH_REPORT_FILE"
else
    echo -e " Memory Status : $MEM_USAGE : OK\n" >> "$HEALTH_REPORT_FILE"
fi

# Send alert if needed
if [ -n "$ALERT_MESSAGES" ]; then
    subject="!!! SYSTEM $HOST HEALTH ALERT !!!"
    echo "$ALERT_MESSAGES" | mail -s "$subject" "$ADMIN_MAIL"
fi

echo "----------------------------------------------------------"
echo "=================================================================================="