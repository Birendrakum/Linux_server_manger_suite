#!/bin/bash  

case "$1" in 
    --health) 
        bash health_check.sh 
        ;; 
    --archive) 
        bash log_archive.sh 
        ;; 
    --rotate) 
        bash log_rotate.sh 
        ;; 
    --service)
        bash service_status_check.sh
        ;;
    --all) 
        bash health_check.sh 
        bash log_archive.sh 
        bash log_rotate.sh 
        bash service_status_check.sh
        ;; 
    *) 
        echo "Usage:" 
        echo " Wrong argument type. Please provide any one arugment" 
        echo "$0 --health" 
        echo " $0 --archive" 
        echo " $0 --rotate"
        echo " $0 --service"
        echo " $0 --all" 
        exit 1 
        ;; 
esac