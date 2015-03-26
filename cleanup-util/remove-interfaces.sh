#!/bin/bash

# delete interfaces created except for then usual suspects, eth, lo, etc
for link in `sudo ip a | grep 'vm\|br\|veth\|tap' | awk '{print $2}' | cut -d':' -f 1`; do
    echo deleting port $link
    sudo ip link delete $link &> /dev/null
done

for ns in $(sudo ip netns list | grep -o  -E '(s|n|test|router|sw|ns)+[a-z0-9]*'); do
    echo "deleting namespace ${ns}"
    sudo ip netns delete ${ns}
done

for br in $(sudo brctl show | tail -1 | awk '{print $1}' | xargs $@ | grep -E '(vswitch|test|br|sw)'); do
    echo "deleting bridge ${br}"
    sudo ip link set ${br} down && sudo brctl delbr ${br}
done

echo done