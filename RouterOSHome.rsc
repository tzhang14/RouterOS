# Home Router with VLAN and L2TP VPN Client
#
# oct/10/2021 20:59:14 by RouterOS 6.48.4
#
# model = 951G-2HnD
# serial number = XXXXXXXXXX
/interface bridge
add name=BR1 protocol-mode=none vlan-filtering=yes
/interface l2tp-client
add connect-to=VPN.EXAMPLE.COM disabled=no ipsec-secret=SECRETKEY \
    keepalive-timeout=disabled name=L2TP-TURNEL password=PASSWORD \
    use-ipsec=yes user=USERNAME
/interface vlan
add interface=BR1 name=GUEST_VLAN vlan-id=20
add interface=BR1 name=IOT_VLAN vlan-id=30
/interface list
add name=WAN
add name=VLAN
add name=LAN
/ip pool
add name=LAN_POOL ranges=192.168.10.21-192.168.10.125
add name=GUEST_POOL ranges=192.168.10.130-192.168.10.190
add name=IOT_POOL ranges=192.168.10.194-192.168.10.254
/ip dhcp-server
add address-pool=LAN_POOL disabled=no interface=BR1 name=LAN_DHCP
add address-pool=GUEST_POOL disabled=no interface=GUEST_VLAN name=GUEST_DHCP
add address-pool=IOT_POOL disabled=no interface=IOT_VLAN name=IOT_DHCP
/queue simple
add burst-limit=512k/1M burst-threshold=256k/512k burst-time=10s/10s \
    disabled=yes max-limit=256k/512k name=IOT_BANDWIDTH target=\
    192.168.10.192/26
add burst-limit=3M/30M burst-threshold=1M/10M burst-time=30s/30s max-limit=\
    1M/10M name=GUEST_BANDWIDTH target=GUEST_VLAN
/system logging action
set 3 remote=192.168.10.5 remote-port=9514
/interface bridge port
add bridge=BR1 ingress-filtering=yes interface=ether1
add bridge=BR1 interface=ether2 pvid=20
add bridge=BR1 interface=ether3 pvid=30
add bridge=BR1 ingress-filtering=yes interface=ether4
/ip neighbor discovery-settings
set discover-interface-list=LAN
/ipv6 settings
set accept-router-advertisements=yes
/interface bridge vlan
add bridge=BR1 tagged=ether1,ether4,BR1 untagged=ether2 vlan-ids=20
add bridge=BR1 tagged=ether1,ether4,BR1 untagged=ether3 vlan-ids=30
/interface list member
add interface=ether5 list=WAN
add interface=GUEST_VLAN list=VLAN
add interface=IOT_VLAN list=VLAN
add interface=BR1 list=LAN
/ip address
add address=192.168.10.126/25 interface=BR1 network=192.168.10.0
add address=192.168.10.129/26 interface=GUEST_VLAN network=192.168.10.128
add address=192.168.10.193/26 interface=IOT_VLAN network=192.168.10.192
/ip dhcp-client
add disabled=no interface=ether5
/ip dhcp-server network
add address=192.168.10.0/25 dns-server=192.168.10.126 gateway=192.168.10.126 \
    netmask=25
add address=192.168.10.128/26 dns-server=192.168.10.126 gateway=\
    192.168.10.129 netmask=26
add address=192.168.10.192/26 dns-server=192.168.10.126 gateway=\
    192.168.10.193 netmask=26
/ip dns
set allow-remote-requests=yes servers=8.8.8.8
/ip firewall address-list
add address=10.160.180.0/24 list=OFFICE-Main-Addresses
add address=192.168.8.0/24 list=OFFICE-PUBVMs-Addresses
add address=192.168.10.0/25 list=Home-Main-Addresses
add address=192.168.10.10 list=PUBAddressForGuest
/ip firewall filter
add action=accept chain=input comment="Allow Estab & Related" \
    connection-state=established,related
add action=accept chain=input comment="Allow VLAN" in-interface-list=VLAN
add action=accept chain=input comment="Allow LAN Full Access" \
    in-interface-list=LAN
add action=drop chain=input comment=Drop
add action=accept chain=forward comment="Allow Estab & Related" \
    connection-state=established,related
add action=accept chain=forward comment="LAN, VLAN Internet Access only" \
    connection-state=new in-interface-list=VLAN out-interface-list=WAN
add action=accept chain=forward in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="Allow LAN to VLAN Access" \
    in-interface-list=LAN out-interface-list=VLAN
add action=accept chain=forward comment="Allow Guest to Sign In " \
    dst-address-list=PUBAddressForGuest in-interface=GUEST_VLAN
add action=accept chain=forward comment="Allow Access OFFICE VPN " \
    dst-address-list=OFFICE-PUBVMs-Addresses src-address-list=\
    Home-Main-Addresses
add action=accept chain=forward dst-address-list=OFFICE-Main-Addresses \
    src-address-list=Home-Main-Addresses
add action=accept chain=forward comment="Allow WAN Ports forwarding" \
    connection-nat-state=dstnat connection-state=new in-interface-list=WAN
add action=drop chain=forward comment=Drop
/ip firewall nat
add action=masquerade chain=srcnat comment="Allow Access OFFICE VPN " \
    dst-address-list=OFFICE-PUBVMs-Addresses out-interface=L2TP-TURNEL \
    src-address-list=Home-Main-Addresses
add action=masquerade chain=srcnat dst-address-list=OFFICE-Main-Addresses \
    out-interface=L2TP-TURNEL src-address-list=Home-Main-Addresses
add action=masquerade chain=srcnat comment="Default masquerade" \
    out-interface-list=WAN
add action=dst-nat chain=dstnat comment="Forward port 102 to appletv port 22" \
    dst-port=102 protocol=tcp to-addresses=192.168.10.19 to-ports=22
add action=dst-nat chain=dstnat comment="Allow ping AppleTV from Internet" \
    in-interface-list=WAN protocol=icmp to-addresses=192.168.10.19
/ip firewall service-port
set ftp disabled=yes
set tftp disabled=yes
set irc disabled=yes
set h323 disabled=yes
set sip disabled=yes
set pptp disabled=yes
set udplite disabled=yes
set dccp disabled=yes
set sctp disabled=yes
/ip route
add check-gateway=ping distance=1 dst-address=10.160.180.0/24 gateway=\
    10.160.180.1
add check-gateway=ping distance=1 dst-address=192.168.8.0/24 gateway=\
    10.160.180.1
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www address=192.168.10.0/25
set ssh address=192.168.10.0/25
set api address=192.168.10.0/25 disabled=yes
set winbox address=192.168.10.0/25
set api-ssl address=192.168.10.0/25 disabled=yes
/ip traffic-flow
set cache-entries=256k enabled=yes interfaces=ether5
/ip traffic-flow target
add dst-address=192.168.10.5 port=4739
/ipv6 address
add address=::1 from-pool=ipv6pool interface=BR1
/ipv6 dhcp-client
add add-default-route=yes interface=ether5 pool-name=ipv6pool \
    pool-prefix-length=60 request=address,prefix
/ipv6 firewall filter
add action=drop chain=input comment="Drop (invalid)" connection-state=invalid
add action=accept chain=input comment="Accept (established, related)" \
    connection-state=established,related
add action=accept chain=input comment="Accept DHCP (10/sec)" in-interface=\
    ether5 limit=10,20:packet protocol=udp src-port=547
add action=drop chain=input comment="Drop DHCP (>10/sec)" in-interface=ether5 \
    protocol=udp src-port=547
add action=accept chain=input comment="Accept external ICMP (10/sec)" \
    in-interface=ether5 limit=10,20:packet protocol=icmpv6
add action=drop chain=input comment="Drop external ICMP (>10/sec)" \
    in-interface=ether5 protocol=icmpv6
add action=accept chain=input comment="Accept internal ICMP" in-interface=\
    !ether5 protocol=icmpv6
add action=drop chain=input comment="Drop external" in-interface=ether5
add action=reject chain=input comment="Reject everything else"
add action=accept chain=output comment="Accept all"
add action=drop chain=forward comment="Drop (invalid)" connection-state=\
    invalid
add action=accept chain=forward comment="Accept (established, related)" \
    connection-state=established,related
add action=accept chain=forward comment="Accept external ICMP (20/sec)" \
    in-interface=ether5 limit=20,50:packet protocol=icmpv6
add action=drop chain=forward comment="Drop external ICMP (>20/sec)" \
    in-interface=ether5 protocol=icmpv6
add action=accept chain=forward comment="Accept internal" in-interface=\
    !ether5
add action=accept chain=forward comment="Accept outgoing" out-interface=\
    ether5
add action=drop chain=forward comment="Drop external" in-interface=ether5
add action=reject chain=forward comment="Reject everything else"
/ipv6 nd
set [ find default=yes ] advertise-dns=no
/system clock
set time-zone-name=America/Chicago
/system identity
set name=HomeRouter
/system ntp client
set enabled=yes primary-ntp=129.6.15.28 secondary-ntp=129.6.15.29 \
    server-dns-names=time.nist.gov