#!/bin/bash

DATA_DIR = "/container/data"
CONF4=""
CONF6=""
IFACE4=""
IFACE6=""


start_dhcpd() # $PROTOCOL $IFACES
{
    # Define names and paths to the leases & config files
    if [ $1 == 4 ]; then
        LEASES_FILE = $DATA_DIR/dhcpd.leases
        if [ -z $CONF4 ]; then
            CONF4 = dhcpd.conf
        fi
        CONF_FILE = $DATA_DIR/$CONF4
        DHCPD_PROTOCOL = "-4"
    elif [ $1 == 6 ]; then
        LEASES_FILE = $DATA_DIR/dhcpd6.leases
        if [ -z $CONF6 ]; then
            CONF6 = dhcpd6.conf
        fi
        CONF_FILE = $DATA_DIR/$CONF6
        DHCPD_PROTOCOL = "-6"
    else
        echo "Protocol incorrectly or not defined when starting dhcpd server:"
        echo "    $1"
        exit 1
    fi

    # Get the interfaces from the second and any subsequent argument
    shift 1
    if [ -z $1 ]; then
        IFACE = " "
    else
        IFACE = $*

    # There is a leases file and ensure ownership of it and the leases backup
    [ -e $LEASES_FILE ] || touch $LEASES_FILE
    chown dhcpd:dhcpd $LEASES_FILE
    if [ -e ${LEASES_FILE}~ ]; then
        chown dhcpd:dhcpd ${LEASES_FILE}~
    fi

    /usr/sbin/dhcpd $DHCPD_PROTOCOL -f -d --no-pid \
                -cf $CONF_FILE \
                -lf $LEASES_FILE \
                $IFACE &
}

shopt -s nocasematch
if [ ! -z $IPV4] || [$IPV4 == "yes"]; then
    PROTO4 = 1
else
    PROTO4 = 0
fi
if [ ! -z $IPV6] || [$IPV6 == "yes"]; then
    PROTO6 = 1
else
    PROTO6 = 0
fi
shopt -u nocasematch

if [ $PROTO4 == 1 ]; then
    echo "Starting dhcpd (IPv4) on $IFACE4"
    start_dhcpd 4 $IFACE4
fi
if [ $PROTO6 = 1 ]; then
    echo "Starting dhcpd6 (IPv6) on $IFACE"
    start_dhcpd 6 $IFACE6
fi
