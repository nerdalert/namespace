#!/bin/bash

################################################################
#                     +----------------------+
#                     | Physical Port/Fabric |
#                     +----------+-----------+
#                                |
#    +---------------------------+----------------------------+
#    |                           NS2                          |
#    |    NS2 - 10.1.200.1/24           NS2 - 10.1.100.1/24   |
#    |                                                        |
#    +-------+BR1_NS2_INT+----------------+BR2_NS2_INT+-------+
#                 +                              +
#                 |                              |
#                 +                              +
#    +-------+BR1-NS2-EXT+------+  +-------+BR2-NS2-EXT+------+
#    |                          |  |                          |
#    |           Br1            |  |            Br2           |
#    |                          |  |                          |
#    +------+BR1-NS1-EXT+-------+  +-------+BR2-NS3-EXT+------+
#                 +                              +
#                 |                              |
#                 +                              +
#    +------+BR1_NS1_INT+-------+  +-------+BR2-NS3-INT+------+
#    |                          |  |                          |
#    |                          |  |                          |
#    |   NS1 - 10.1.200.20/24   |  |    NS3 - 10.1.100.20/24  |
#    +-------+------------------+  +--------+-----------------+
################################################################

echo 1 > /proc/sys/net/ipv4/ip_forward

iptables -F

# The common bridge both namespaces tap into
export BRIDGE1=br1
export BRIDGE2=br2

# Internal ports (int) are inside a namespace,
# External ports (ext) are in then common bridge
export BR1_NS1=ns1
export BR1_NS1_INT=v0-br1-ns1-int
export BR1_NS1_EXT=v0-br1-ns1-ext

export BR1_NS2=ns2
export BR1_NS2_INT=v0-br1-ns2-int
export BR1_NS2_EXT=v0-br1-ns2-ext

export BR2_NS3=ns3
export BR2_NS2_INT=v0-br2-ns2-int
export BR2_NS2_EXT=v0-br2-ns2-ext

export BR2_NS3_INT=v0-br2-ns3-int
export BR2_NS3_EXT=v0-br2-ns3-ext

ip netns add $BR1_NS1
ip link add name $BR1_NS1_INT type veth peer name $BR1_NS1_EXT
ip link set $BR1_NS1_EXT netns $BR1_NS1

ip netns exec $BR1_NS1 ip link set $BR1_NS1_EXT up
ip netns exec $BR1_NS1 ip link set lo up
ip netns exec $BR1_NS1 ip addr add 10.1.200.20/24 dev $BR1_NS1_EXT

ip netns add $BR1_NS2
ip link add name $BR1_NS2_INT type veth peer name $BR1_NS2_EXT
ip link set $BR1_NS2_EXT netns $BR1_NS2
ip netns exec $BR1_NS2 ip link set lo up
ip netns exec $BR1_NS2 ip link set $BR1_NS2_EXT up
ip netns exec $BR1_NS2 ip addr add 10.1.200.1/24 dev $BR1_NS2_EXT

brctl addbr $BRIDGE1
brctl setfd $BRIDGE1 0
brctl addif $BRIDGE1 $BR1_NS1_INT
brctl addif $BRIDGE1 $BR1_NS2_INT
ip link set $BR1_NS1_INT up
ip link set $BR1_NS2_INT up
ip link set $BRIDGE1 up

ip link add name $BR2_NS3_INT type veth peer name $BR2_NS3_EXT
ip link set $BR2_NS3_EXT netns $BR1_NS2
ip netns exec $BR1_NS2 ip link set lo up
ip netns exec $BR1_NS2 ip link set $BR2_NS3_EXT up
ip netns exec $BR1_NS2 ip addr add 10.1.100.1/24 dev $BR2_NS3_EXT

ip netns add $BR2_NS3
ip link add name $BR2_NS2_INT type veth peer name $BR2_NS2_EXT
ip link set $BR2_NS2_EXT netns $BR2_NS3
ip netns exec $BR2_NS3 ip link set lo up
ip netns exec $BR2_NS3 ip link set $BR2_NS2_EXT up
ip netns exec $BR2_NS3 ip addr add 10.1.100.20/24 dev $BR2_NS2_EXT

brctl addbr $BRIDGE2
brctl setfd $BRIDGE2 0
brctl addif $BRIDGE2 $BR2_NS3_INT
brctl addif $BRIDGE2 $BR2_NS2_INT
ip link set $BR2_NS3_INT up
ip link set $BR2_NS2_INT up
ip link set $BRIDGE2 up

ip netns exec $BR1_NS1 route add default gw 10.1.200.1
ip netns exec $BR2_NS3 route add default gw 10.1.100.1

brctl show

# All of then following should succeed
ip netns exec $BR1_NS1 ping -c 2 10.1.200.1
ip netns exec $BR1_NS1 ping -c 2 10.1.100.20
ip netns exec $BR1_NS2 ping -c 2 10.1.100.20
ip netns exec $BR2_NS3 ping -c 4 10.1.200.1
ip netns exec $BR1_NS2 ping -c 2 10.1.100.20
ip netns exec $BR1_NS2 ping -c 2 10.1.200.20



