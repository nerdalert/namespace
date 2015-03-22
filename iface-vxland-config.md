
### Host #1 Configuration (Host IP: $HOST1) ###

##### Install Pre-reqs

    apt-get install bridge-utils iproute2

##### Verify VXLAN is compiled in-kernel (returns 0 if true)

    modprobe vxlan && echo $?

if it returns false:

    # Add wheezy backport for iproute2
    echo deb http://http.debian.net/debian wheezy-backports main > \
    /etc/apt/sources.list.d/wheezy-backports.list

    # Install from backport for vlan type support
    apt-get update && apt-get -t wheezy-backports install -y iproute2
    apt-get update && apt-get install -y bridge-utils

*Note* For persistance, netns configs need to be added to iface files (ex. /etc/network/interfaces) or add to something like rc.local depending on OS.

##### Host Addrs #####

    HOST1=172.16.86.142
    HOST2=172.16.86.143

This has differently named netns namespaces. They can be named the same as long as on separate boxes as the name is only locally significant.

#####  Host 1 netns (Host IP: $HOST1)

*Note:* the MTU hack.

    ip netns add ns1
    ip link add veth0 type veth peer name veth0-ns1
    ip link set veth0-ns1 up

    ip link set veth0 netns ns1
    ip netns exec ns1 ip link set veth0 up
    ip netns exec ns1 ip address add 192.168.10.2/24 dev veth0 up
    ip netns exec ns1 ip link set dev lo up
    ip netns exec ns1 ip link set dev veth0 mtu 1400

#####  Host 1 Bridge (Host IP: $HOST1)

    brctl addbr br1
    brctl stp br1 on
    brctl addif br1 veth0-ns1

##### Host 1  point2point  VXLAN (Host IP: $HOST1)

    ip link add vxlan-300 type vxlan id 300 dev eth0 remote $HOST2  dstport 0
    ip link set vxlan-300 up
    brctl addif br1 vxlan-300

### Host #2 Configuration (Host IP: $HOST2) ###

##### Host 2  (Host IP: $HOST2)

*Note:* the MTU hack.

    ip netns add ns2
    ip link add veth0 type veth peer name veth0-ns2
    ip link set veth0-ns2 up
    ip link set veth0 netns ns2

    ip netns exec ns2 ip link set veth0 up
    ip netns exec ns2 ip address add 192.168.10.3/24 dev veth0
    ip netns exec ns2 ip link set dev lo up
    ip netns exec ns2 ip link set dev veth0 mtu 1400

##### Host 2 Bridge (Host IP: $HOST2)

    brctl addbr br2
    brctl stp br2 on
    brctl addif br2 veth0-ns2

##### Host 2 point2point VXLAN (Host IP: $HOST2)


    ip link add  vxlan-300 type vxlan id 300 dev eth0 remote $HOST1 dstport 0
    ip link set vxlan-300 up
    brctl addif br2 vxlan-300


### Optional Multicast

You can use multicast to prune what nodes get flooded with the following rather then specifying point-to-point tunnels.

##### (Another options) Multicast replication (Not tested yet )

     ip link add vxlan-500 type vxlan id 500 dev eth0 group 224.0.0.1
     ip link set vxlan-500 up
     brctl addif br1 vxlan-500


##### Multicast replication (Not tested yet )

     ip link add vxlan-500 type vxlan id 500 dev eth0 group 224.0.0.1
     ip link set vxlan-500 up
     brctl addif br1 vxlan-500

























