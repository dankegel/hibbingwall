#!/bin/sh
set -x
for host in `cat whitelist.txt | grep -v '^#' | grep .`
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

dig -t txt _netblocks.google.com | grep '^_netblocks' | sed 's/"$//;s/.*"//' | tr ' ' '\012' | grep / | sed 's/ip4://'
