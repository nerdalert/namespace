## Output from $HOST2

`ip netns exec ns1 ifconfig`

      lo        Link encap:Local Loopback
                inet addr:127.0.0.1  Mask:255.0.0.0
                inet6 addr: ::1/128 Scope:Host
                UP LOOPBACK RUNNING  MTU:65536  Metric:1
                RX packets:4 errors:0 dropped:0 overruns:0 frame:0
                TX packets:4 errors:0 dropped:0 overruns:0 carrier:0
                collisions:0 txqueuelen:0
                RX bytes:336 (336.0 B)  TX bytes:336 (336.0 B)

      veth0     Link encap:Ethernet  HWaddr 7e:9e:a7:ab:bd:82
                inet addr:192.168.100.2  Bcast:0.0.0.0  Mask:255.255.255.0
                inet6 addr: fe80::7c9e:a7ff:feab:bd82/64 Scope:Link
                UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
                RX packets:935 errors:0 dropped:0 overruns:0 frame:0
                TX packets:50 errors:0 dropped:0 overruns:0 carrier:0
                collisions:0 txqueuelen:1000
                RX bytes:53511 (52.2 KiB)  TX bytes:58372 (57.0 KiB)

`ip netns exec ns1 ping 192.168.100.3`

    PING 192.168.100.3 (192.168.100.3) 56(84) bytes of data.
    64 bytes from 192.168.100.3: icmp_seq=1 ttl=64 time=0.567 ms
    64 bytes from 192.168.100.3: icmp_seq=2 ttl=64 time=0.668 ms


Arp from global tables (note 192.168.100.x does not appear, only the ARP entry from the TEP)

`arp`

    Address                  HWtype  HWaddress           Flags Mask            Iface
    172.16.86.2              ether   00:50:56:eb:bf:77   C                     eth0
    172.16.86.1              ether   00:50:56:c0:00:02   C                     eth0
    172.16.86.143            ether   00:50:56:39:2a:79   C                     eth0

Arp from namespace ns1 (note 192.168.100.x does appear)

`ip netns exec ns1 arp`

      Address                  HWtype  HWaddress           Flags Mask            Iface
      192.168.100.3            ether   fa:9e:8e:29:1b:c8   C                     veth0


