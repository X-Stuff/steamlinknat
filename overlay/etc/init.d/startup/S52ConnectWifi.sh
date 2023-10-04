#!/bin/sh

AP_NAME=`cat /etc/wifi.ap`

main()
{
    #
    echo "Running in backround"

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

    # Renew DHCP (Set up routes and /etc/resolv.conf)
    # IMPORTANT: This will set up correct routes and dns
    udhcpc -i mlan0 -s /etc/udhcpc.script -n -q
}

# disable bg version
main

#BACKGROUND_ARG="--background"
#
#if [ "$1" != "$BACKGROUND_ARG" ];
#then
#    echo "Launching in backround"
#    /bin/sh $0 $BACKGROUND_ARG &
#else
#    main
#fi
