#!/bin/bash
# Description: Sets all network interfaces to use OpenDNS Home servers, but only
# for the network interfaces that are not compliant.

function non_opendns_home_dns {
    INTERFACE=$1
    if [ "$INTERFACE" = "An asterisk (*) denotes that a network service is disabled." ]; then
        echo 0
    else
        DNS=$(networksetup -getdnsservers "$INTERFACE" | tr -d "\n")
        if [ "$DNS" != "208.67.222.222208.67.220.220" ]; then
            echo 1
        else
            echo 0
        fi
    fi
}
export -f non_opendns_home_dns

function set_opendns_home_dns {
    INTERFACE=$1
    sudo networksetup -setdnsservers "$INTERFACE" 208.67.222.222 208.67.220.220
}
export -f set_opendns_home_dns


function process {
    INTERFACE=$1
    IS_NON_OPENDNS_HOME_DNS=$(non_opendns_home_dns "$INTERFACE")
    if [ "$IS_NON_OPENDNS_HOME_DNS" = "1" ]; then
        set_opendns_home_dns "$INTERFACE"
    fi
}
export -f process

networksetup listallnetworkservices | xargs -I{} bash -c 'process "{}"'
