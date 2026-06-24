#!/bin/bash

set -euo pipefail

source ./config.conf

MESSAGES="SERVICE RUNNING STATUS\n----------------------"

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "Service $service: 
STATUS: RUNNING"
    else
        MESSAGES+="
Service $service:
STATUS: NOT RUNNING\n"
    fi
done

if [ -n "$MESSAGES" ]; then
    subject="!!! Service Status NOT RUNNING !!!"
    echo "$MESSAGES" | mail -s "$subject" "$ADMIN_MAIL"
fi
