
### Host #2 Configuration (Host IP: $HOST2) ###

#### Install Pre-reqs

### See host 1 config.

##### Host Addrs #####

    export HOST1=172.16.86.142
    export HOST2=172.16.86.143

##### Host 2  (Host IP: $HOST2)

### *Note:* the MTU hack.

    ip netns add ns2

    # create a pair of interfaces, they will both appear in the default namespace
    # until one end is added to a namespace in the 'ip link set veth0 netns ns2' cmd.

    ip link add veth0 type veth peer name veth0-ns2
    ip link set veth0-ns2 up

    # this will remove veth0 from appearing in the default 'ip route' namespace
    # and will now only appear in the ns2 namespace ex. 'ip netns exec ns2 ip address'

    ip link set veth0 netns ns2

    # bring the iface in the namespace up and assign it an ip address

    ip netns exec ns2 ip link set veth0 up
    ip netns exec ns2 ip address add 192.168.10.3/24 dev veth0
    ip netns exec ns2 ip link set dev lo up
    ip netns exec ns2 ip link set dev veth0 mtu 1400

##### Host 2 Bridge (Host IP: $HOST2)

    brctl addbr br2
    brctl stp br2 on
    brctl addif br2 veth0-ns2

#### *(optionally but if in doubt it is safer)* turn on STP

    brctl stp  br2 off

##### Host 2 point2point VXLAN (Host IP: $HOST2)

    # create a new interface and attach it to the common bridge
    # you can either specify the vxlan port it let it default
    ip link add  vxlan-300 type vxlan id 300 dev eth0 remote ${HOST1} dstport 0
    ip link set vxlan-300 up
    brctl addif br2 vxlan-300

### Optional Multicast Replication

### You can use multicast to prune what nodes get flooded with the following rather then specifying point-to-point tunnels.

     ip link add vxlan-300 type vxlan id 300 dev eth0 group 239.0.0.10
