## Output from $HOST1


`ip netns exec ns2 ifconfig`

    lo        Link encap:Local Loopback
              inet addr:127.0.0.1  Mask:255.0.0.0
              inet6 addr: ::1/128 Scope:Host
              UP LOOPBACK RUNNING  MTU:65536  Metric:1
              RX packets:2 errors:0 dropped:0 overruns:0 frame:0
              TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:0
              RX bytes:168 (168.0 B)  TX bytes:168 (168.0 B)

    veth0     Link encap:Ethernet  HWaddr fa:9e:8e:29:1b:c8
              inet addr:192.168.100.3  Bcast:0.0.0.0  Mask:255.255.255.0
              inet6 addr: fe80::f89e:8eff:fe29:1bc8/64 Scope:Link
              UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
              RX packets:196 errors:0 dropped:0 overruns:0 frame:0
              TX packets:14 errors:0 dropped:0 overruns:0 carrier:0
              collisions:0 txqueuelen:1000
              RX bytes:12641 (12.3 KiB)  TX bytes:1068 (1.0 KiB)


`ip netns exec ns2 ping 192.168.100.2`

    PING 192.168.100.2 (192.168.100.2) 56(84) bytes of data.
    64 bytes from 192.168.100.2: icmp_seq=1 ttl=64 time=0.407 ms
    ^C
    --- 192.168.100.2 ping statistics ---
    1 packets transmitted, 1 received, 0% packet loss, time 0ms
    rtt min/avg/max/mdev = 0.407/0.407/0.407/0.000 ms

Arp from global tables (note 192.168.100.x does not appear)

`arp`

    Address                  HWtype  HWaddress           Flags Mask            Iface
    172.16.86.2              ether   00:50:56:eb:bf:77   C                     eth0
    172.16.86.1              ether   00:50:56:c0:00:02   C                     eth0
    172.16.86.142            ether   00:0c:29:d5:ac:77   C                     eth0

Arp from namespace ns2 (note 192.168.100.x does appear)

`ip netns exec ns2 arp`

    Address                  HWtype  HWaddress           Flags Mask            Iface
    192.168.100.2            ether   7e:9e:a7:ab:bd:82   C                     veth0


Example logs


    Mar 22 07:10:38 deb-142 kernel: [  289.367934] device vxlan-200 entered promiscuous mode
    Mar 22 07:10:38 deb-142 kernel: [  289.367950] br1: port 2(vxlan-200) entered listening state
    Mar 22 07:10:38 deb-142 kernel: [  289.367953] br1: port 2(vxlan-200) entered listening state
    Mar 22 07:10:38 deb-142 avahi-daemon[4764]: Joining mDNS multicast group on interface vxlan-200.IPv6 with address fe80::3c90:d7ff:fecb:2050.
    Mar 22 07:10:38 deb-142 avahi-daemon[4764]: New relevant interface vxlan-200.IPv6 for mDNS.
    Mar 22 07:10:38 deb-142 avahi-daemon[4764]: Registering new address record for fe80::3c90:d7ff:fecb:2050 on vxlan-200.*.
    Mar 22 07:10:41 deb-142 kernel: [  293.046165] br1: port 1(veth0-ns1) entered learning state
    Mar 22 07:10:53 deb-142 kernel: [  304.370230] br1: port 2(vxlan-200) entered learning state
    Mar 22 07:10:56 deb-142 kernel: [  308.080788] br1: topology change detected, propagating
    Mar 22 07:10:56 deb-142 kernel: [  308.080803] br1: port 1(veth0-ns1) entered forwarding state
    Mar 22 07:11:08 deb-142 kernel: [  319.404745] br1: topology change detected, propagating
    Mar 2 deb-142 kernel: [  319.404841] br1: port 2(vxlan-200) entered forwarding state


`(ARP) arping -c 1 192.168.100.3`

    ARPING 192.168.100.3 from 192.168.100.2 veth0
    Unicast reply from 192.168.100.3 [FA:9E:8E:29:1B:C8]  1.074ms
    Sent 1 probes (1 broadcast(s))
    Received 1 response(s)

Performance test using iperf on the server side:

`ip netns exec ns2 iperf -s`

    ------------------------------------------------------------
    Server listening on TCP port 5001
    TCP window size: 85.3 KByte (default)
    ------------------------------------------------------------
    [  4] local 192.168.10.2 port 5001 connected with 192.168.10.1 port 38185
    [ ID] Interval       Transfer     Bandwidth
    [  4]  0.0-10.0 sec  1.12 GBytes   958 Mbits/sec

On the client side:

`ip netns exec ns2 iperf -c 192.168.10.2`

    ------------------------------------------------------------
    Client connecting to 192.168.10.2, TCP port 5001
    TCP window size: 45.0 KByte (default)
    ------------------------------------------------------------
    [  3] local 192.168.100.1 port 38185 connected with 192.168.10.2 port 5001
    [ ID] Interval       Transfer     Bandwidth
    [  3]  0.0-10.0 sec  1.12 GBytes   960 Mbits/sec