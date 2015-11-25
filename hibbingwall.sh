#!/bin/sh
set -e
browsers="firefox|chrome"

expand_addrs() {
    for host
    do
        case $host in
        *[a-zA-Z]*)
            host $host | grep 'address' | sed 's/.* //' > host.tmp
            cat host.tmp
            # show it to stderr, too, so it doesn't disappear into a pipe
            cat host.tmp >&2
            rm host.tmp
            ;;
        *) echo $host;;
        esac
    done
}

addr_to_net() {
   # FIXME: actually pay attention to size of address
   echo $1 | sed 's,255/.*,0,'
}

do_start() {
    export LANG=C
    unset LOCALE
    echo y | ufw reset
    ufw default deny incoming
    ufw default deny outgoing
    # NTP
    ufw allow in proto udp from any port 123
    ufw allow out proto udp to any port 123
    ufw allow in proto tcp from any port 123
    ufw allow out proto tcp to any port 123
    # DNS
    ufw allow in proto udp from any port 53
    ufw allow out proto udp to any port 53
    ufw allow in proto tcp from any port 53
    ufw allow out proto tcp to any port 53
    # DHCP
    ufw allow in proto udp from any port 67
    ufw allow out proto udp to any port 67
    ufw allow in proto udp from any port 68
    ufw allow out proto udp to any port 68

    # local stuff
    for addr in `ip addr | awk '/inet.* brd / {print $2}'`
    do
        net=`addr_to_net $addr`
        ufw allow in proto tcp from $net
        ufw allow out proto tcp to $net
    done

    for block in `cat $whitelist | grep -v '^#' | grep .`
    do
        ufw allow in proto tcp from $block
        ufw allow out proto tcp to $block
    done

    ufw enable
    ufw status
}

do_add() {
    if test "$1" = ""
    then
        addrs=`netstat -p -t --wide | grep SYN | egrep "$browsers" | awk '{print $5}' | sed 's/:.*//' | sort -u | fgrep -w -v -f $whitelist || true`
        if test "$addrs" = ""
        then
            echo "Nothing to add"
            return 0
        fi
        echo "Adding addresses $addrs"
        set $addrs
    fi
    for a
    do
        echo $a >> $whitelist
    done
    expanded=`expand_addrs $addrs`
    echo "Unblocking $expanded"
    for block in $expanded
    do
        ufw allow in proto tcp from $block || true
        ufw allow out proto tcp to $block || true
    done
    echo "Done adding"
}

do_learn() {
    tries=100
    case "$1" in
    [0-9]*) tries=`expr $1 \* 60`;;
    esac
    while test $tries -gt 0
    do
        do_add
        tries=`expr $tries - 1`
        sleep 5
    done
}

do_clear() {
    mkdir -p $confdir
    echo "" > $whitelist
}

do_pull() {
    mkdir -p $confdir
    # FIXME: provide shared storage for each site so they don't have to use mine
    wget -O $whitelist https://raw.githubusercontent.com/dankegel/hibbingwall/master/whitelist.txt
}

do_usage() {
    echo "Usage:"
    echo "$0 clear"
    echo "$0 pull"
    echo "$0 start"
    echo "$0 add addr ... "
    echo "$0 learn [minutes]"
}

confdir=/etc/hibbingwall
whitelist=$confdir/whitelist.txt

cmd=$1
test "$cmd" && shift
case "$cmd" in
clear) do_clear ;;
pull) do_pull ;;
start) do_start ;;
add) do_add "$@";;
learn) do_learn $1;;
*) do_usage; exit 1;;
esac

