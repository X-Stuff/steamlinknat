#!/bin/sh

AP_NAME=`cat /etc/wifi.ap`
AP_MAC=`cat /etc/wifi.mac`

rerun_dhcp_mlan0()
{
    # Renew DHCP (Set up routes and /etc/resolv.conf)
    # IMPORTANT: This will set up correct routes and dns
    udhcpc -i mlan0 -s /etc/udhcpc.script -n -q
    return $?
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
            sleep 2
            RETRIES=$((RETRIES+1))

            if [ $RETRIES -eq 5 ]
            then
                echo "Failed to connecto to $AP_NAME after 5 attempt."
                exit 1
            fi
        done
    fi

    rerun_dhcp_mlan0
    return $?
}


wifi_watchdog()
{
    local PREV_IP=`ip -f inet addr show mlan0 | grep inet | awk '{print $2}' | cut -d "/" -f 1`

    if [ "$PREV_IP" == "" ]; then
        echo "Watchdog will not run. Doesn't have WiFi IP"
        exit 1;
    fi

    while true; do
        sleep 30

        LAST_WATCHDOG_PID=`cat /tmp/wifi.watchdog.pid`
        if [ "$LAST_WATCHDOG_PID" != $1 ]; then
            echo "New watchdog launch detected. PID: $1 exiting now"
            exit 0
        fi

        local NEW_IP=`ip -f inet addr show mlan0 | grep inet | awk '{print $2}' | cut -d "/" -f 1`

        if [ "$NEW_IP" != "$PREV_IP" ]; then
            echo "Wifi IP address changed. Rerunning DHCP again, with script."
            rerun_dhcp_mlan0
        fi

        local DEFAULT_ROUTE=`ip route | grep default | awk '{print $3}'`

        if [ "$DEFAULT_ROUTE" == "" ]; then
            echo "No default route found. Rerunning DHCP again, with script."
            rerun_dhcp_mlan0
        fi

        PREV_IP=$NEW_IP
    done
}

WATCHDOG_ARG="--watchdog"

if [ "$1" == "" ]; then

    # Do main job
    main

    if [ "$?" == "0" ]; then
        # Launch watchdog
        /bin/sh $0 $WATCHDOG_ARG &
        exit 0
    else
        echo "Failed to obtain IP address!"
        echo "Checking with ARP gateway IP"

        local GW_IP=`arp -i mlan0 | grep "$AP_MAC" | awk '{print $2}' | tr -d "()"`

        if [ "$GW_IP" == "" ]; then
            echo "Can't get GW Ip address with arp"
        else
            echo "GW IP address is $GW_IP. Try to set it manually."
        fi
    fi
fi

if [ "$1" == "$WATCHDOG_ARG" ];
then
   echo "$$" > /tmp/wifi.watchdog.pid
   echo "Running watchdog"
   wifi_watchdog "$$"
fi
