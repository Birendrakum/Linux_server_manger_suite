#!/bin/bash 
source ./config.conf 
mkdir -p logs backups 
case "$1" in 
  --health) 
    bash health_check.sh 
    ;; 
  --backup) 
    bash backup.sh 
    ;; 
  --rotate) 
    bash log_rotate.sh 
    ;; 
  --cleanup) 
    bash cleanup.sh 
    ;; 
  --all) 
    bash health_check.sh 
    bash backup.sh 
    bash log_rotate.sh 
    bash cleanup.sh 
    ;; 
  *) 
    echo "Usage:" 
    echo " Wrong argument type. Please provide any one arugment" 
    echo "$0 --health" 
    echo " $0 --backup" 
    echo " $0 --rotate" 
    echo " $0 --cleanup" 
    echo " $0 --all" 
    exit 1 
    ;; 
esac