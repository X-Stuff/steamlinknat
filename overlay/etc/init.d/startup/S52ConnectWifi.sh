#!/bin/sh

AP_NAME=`cat /etc/wifi.ap`

rerun_dhcp_mlan0()
{
    # Renew DHCP (Set up routes and /etc/resolv.conf)
    # IMPORTANT: This will set up correct routes and dns
    udhcpc -i mlan0 -s /etc/udhcpc.script -n -q
}

main()
{
    #
    echo "Scanning wifi..."
    connmanctl scan wifi

    # Connect WiFi
    
    AP_SERVICE=`connmanctl services | grep $AP_NAME`

    if [ "$AP_SERVICE" == "" ]; then
        echo "Wifi AP $AP_NAME not found..."
        exit 1
    else
        echo "Found service $AP_SERVICE"
    fi

    if [ $(expr match "$AP_SERVICE" '\*') ]; then
        echo "Wifi AP $AP_NAME already connected"
    else
        echo "Trying to connect to AP: $AP_NAME"
        RETRIES=0

        AP_SERVICE_ID=`echo "$AP_SERVICE" | awk '{print $3 }'`

        while connmanctl connect $AP_SERVICE_ID > /dev/null; [ $? -ne 0 ];
        do
            echo "Cannot connect to $AP_NAME. Retrying in 2 seconds..."
            sleep 1
            RETRIES=$((RETRIES+1))

            if [ $RETRIES -eq 5 ]
            then
                exit 1
            fi
        done
    fi

    rerun_dhcp_mlan0
}


wifi_watchdog()
{
    local PREV_IP=`ip -f inet addr show mlan0 | grep inet | awk '{print $2}' | cut -d "/" -f 1`

    while true; do
    
        local NEW_IP=`ip -f inet addr show mlan0 | grep inet | awk '{print $2}' | cut -d "/" -f 1`

        if [ $NEW_IP != $PREV_IP ]; then
            echo "Wifi IP address changed. Rerunning DHCP again, with script."
            rerun_dhcp_mlan0
        fi

        PREV_IP=$NEW_IP
        sleep 30
    done     
}

WATCHDOG_ARG="--watchdog"

if [ "$1" == "" ]; then
    
    # Do main job
    main

    # Launch watchdog
    /bin/sh $0 $WATCHDOG_ARG &
    exit 0
fi

if [ "$1" == "$WATCHDOG_ARG" ];
then
   echo "Running watchdog"
   wifi_watchdog
fi
