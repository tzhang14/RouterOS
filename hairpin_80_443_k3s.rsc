# 2024-10-28 12:28:48 by RouterOS 7.16.1
# software id = BU8Q-CSUN
#
# model = RB5009UG+S+
# serial number = EC1A0EBF3345
/interface bridge
add ingress-filtering=no name=BR1 port-cost-mode=short protocol-mode=none \
    vlan-filtering=yes
/interface ethernet
set [ find default-name=sfp-sfpplus1 ] disabled=yes
/interface l2tp-client
add connect-to=dell.yuenlawoffice.com disabled=no keepalive-timeout=disabled \
    max-mru=1420 max-mtu=1420 name=YLO-L2TP-TURNEL use-ipsec=yes user=tony
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
add address-pool=LAN_POOL interface=BR1 lease-time=1h name=LAN_DHCP
add address-pool=GUEST_POOL interface=GUEST_VLAN name=GUEST_DHCP
add address-pool=IOT_POOL interface=IOT_VLAN lease-time=1h name=IOT_DHCP
/ip smb users
set [ find default=yes ] disabled=yes
/queue simple
add burst-limit=512k/1M burst-threshold=256k/512k burst-time=10s/10s \
    disabled=yes max-limit=256k/512k name=IOT_BANDWIDTH target=\
    192.168.10.192/26
add burst-limit=3M/30M burst-threshold=1M/10M burst-time=30s/30s max-limit=\
    1M/10M name=GUEST_BANDWIDTH target=GUEST_VLAN
/system logging action
set 3 remote=192.168.10.15 remote-port=8514
add name=splunk remote=192.168.10.15 remote-port=8514 target=remote
/interface bridge port
add bridge=BR1 interface=ether1 internal-path-cost=10 path-cost=10
add bridge=BR1 ingress-filtering=no interface=ether2 internal-path-cost=10 \
    path-cost=10 pvid=20
add bridge=BR1 ingress-filtering=no interface=ether3 internal-path-cost=10 \
    path-cost=10 pvid=30
add bridge=BR1 interface=ether4 internal-path-cost=10 path-cost=10
add bridge=BR1 interface=ether5 internal-path-cost=10 path-cost=10
add bridge=BR1 interface=ether6 internal-path-cost=10 path-cost=10
add bridge=BR1 interface=ether7 internal-path-cost=10 path-cost=10
/ip firewall connection tracking
set udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=LAN
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set accept-router-advertisements=yes max-neighbor-entries=8192
/interface bridge vlan
add bridge=BR1 tagged=ether1,ether4,ether5,ether6,ether7,BR1 untagged=ether2 \
    vlan-ids=20
add bridge=BR1 tagged=ether1,ether4,ether5,ether6,ether7,BR1 untagged=ether3 \
    vlan-ids=30
/interface detect-internet
set detect-interface-list=all
/interface list member
add interface=ether8 list=WAN
add interface=GUEST_VLAN list=VLAN
add interface=IOT_VLAN list=VLAN
add interface=BR1 list=LAN
/interface ovpn-server server
set auth=sha1,md5
/ip address
add address=192.168.10.126/25 interface=BR1 network=192.168.10.0
add address=192.168.10.129/26 interface=GUEST_VLAN network=192.168.10.128
add address=192.168.10.193/26 interface=IOT_VLAN network=192.168.10.192
/ip arp
add address=192.168.10.15 interface=BR1 mac-address=6C:2B:59:F0:D6:3A
/ip cloud
set ddns-enabled=yes ddns-update-interval=5m
/ip cloud advanced
set use-local-address=yes
/ip dhcp-client
add interface=ether8
/ip dhcp-server lease
add address=192.168.10.2 client-id=1:24:5a:4c:75:c9:7e mac-address=\
    24:5A:4C:75:C9:7E server=LAN_DHCP
add address=192.168.10.19 client-id=1:28:e7:cf:e1:bc:4d mac-address=\
    28:E7:CF:E1:BC:4D server=LAN_DHCP
add address=192.168.10.6 client-id=1:9c:ad:ef:60:56:fa mac-address=\
    9C:AD:EF:60:56:FA server=LAN_DHCP
add address=192.168.10.60 client-id=1:30:5:5c:2d:1f:c9 mac-address=\
    30:05:5C:2D:1F:C9 server=LAN_DHCP
add address=192.168.10.15 client-id=1:6c:2b:59:f0:d6:3a mac-address=\
    6C:2B:59:F0:D6:3A server=LAN_DHCP
add address=192.168.10.12 client-id=1:d8:3a:dd:44:1b:e6 mac-address=\
    D8:3A:DD:44:1B:E6 server=LAN_DHCP
add address=192.168.10.13 client-id=1:d8:3a:dd:44:1b:ab mac-address=\
    D8:3A:DD:44:1B:AB server=LAN_DHCP
add address=192.168.10.11 client-id=1:d8:3a:dd:44:1b:23 mac-address=\
    D8:3A:DD:44:1B:23 server=LAN_DHCP
/ip dhcp-server network
add address=192.168.10.0/25 dns-server=192.168.10.126,8.8.8.8 domain=ezit.me \
    gateway=192.168.10.126 netmask=25 ntp-server=129.6.15.28,129.6.15.29
add address=192.168.10.128/26 dns-server=192.168.10.126,8.8.8.8 gateway=\
    192.168.10.129 netmask=26 ntp-server=129.6.15.28,129.6.15.29
add address=192.168.10.192/26 dns-server=192.168.10.126,8.8.8.8 gateway=\
    192.168.10.193 netmask=26 ntp-server=129.6.15.28,129.6.15.29
/ip dns
set allow-remote-requests=yes servers=8.8.8.8,192.168.10.126
/ip firewall address-list
add address=10.160.180.0/24 list=YLO-Main-Addresses
add address=192.168.8.0/24 list=YLO-PUBVMs-Addresses
add address=192.168.10.0/25 list=Home-Main-Addresses
add address=192.168.10.10 list=PUBAddressForGuest
add address=192.168.10.1-192.168.10.4 comment="Internal IP list" list=\
    Internal_addresses
add address=192.168.10.6-192.168.10.254 comment="Internal IP list" list=\
    Internal_addresses
/ip firewall filter
add action=accept chain=input comment="Allow Estab & Related" \
    connection-state=established,related
add action=accept chain=input comment="Allow VLAN" in-interface-list=VLAN
add action=accept chain=input comment="Allow LAN Full Access" \
    in-interface-list=LAN
add action=accept chain=forward comment="Allow Estab & Related" \
    connection-state=established,related
add action=accept chain=forward comment="LAN, VLAN Internet Access only" \
    connection-state=new in-interface-list=VLAN out-interface-list=WAN
add action=accept chain=forward in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="Allow LAN to VLAN Access" \
    in-interface-list=LAN out-interface-list=VLAN
add action=accept chain=forward comment=\
    "Allow forward traffic for port redirections and DMZ" \
    connection-nat-state=dstnat
add action=accept chain=forward disabled=yes dst-address=192.168.10.128/25 \
    src-address=192.168.10.0/25
add action=accept chain=forward comment="Allow Guest to Sign In " \
    dst-address-list=PUBAddressForGuest in-interface=GUEST_VLAN
add action=accept chain=forward comment="Allow Access YLO VPN " \
    dst-address-list=YLO-PUBVMs-Addresses src-address-list=\
    Home-Main-Addresses
add action=accept chain=forward dst-address-list=YLO-Main-Addresses \
    src-address-list=Home-Main-Addresses
add action=accept chain=forward comment="Allow WAN Ports forwarding" \
    connection-nat-state=dstnat connection-state=new in-interface-list=WAN
add action=drop chain=input comment=Drop
add action=drop chain=forward comment=Drop
/ip firewall nat
add action=masquerade chain=srcnat comment="Allow Access YLO VPN " \
    dst-address-list=YLO-PUBVMs-Addresses out-interface=YLO-L2TP-TURNEL \
    src-address-list=Home-Main-Addresses
add action=masquerade chain=srcnat dst-address-list=YLO-Main-Addresses \
    out-interface=YLO-L2TP-TURNEL src-address-list=Home-Main-Addresses
add action=masquerade chain=srcnat comment="Default masquerade" \
    out-interface-list=WAN
add action=dst-nat chain=dstnat comment="Forward port 80 443 to k3s" \
    dst-address-list=!Internal_addresses dst-address-type=local dst-port=443 \
    log=yes log-prefix=dstnat protocol=tcp to-addresses=192.168.10.5 \
    to-ports=443
add action=dst-nat chain=dstnat dst-address-list=!Internal_addresses \
    dst-address-type=local dst-port=80 log=yes log-prefix=dstnat protocol=tcp \
    to-addresses=192.168.10.5 to-ports=80
add action=masquerade chain=srcnat comment=HairpinNat dst-address-list=\
    !Internal_addresses protocol=tcp src-address=192.168.10.0/25
add action=dst-nat chain=dstnat comment="Allow ping AppleTV from Internet" \
    in-interface-list=WAN protocol=icmp to-addresses=192.168.10.19
/ip firewall service-port
set ftp disabled=yes
set tftp disabled=yes
set h323 disabled=yes
set sip disabled=yes
set pptp disabled=yes
set udplite disabled=yes
set dccp disabled=yes
set sctp disabled=yes
/ip ipsec profile
set [ find default=yes ] dpd-interval=2m dpd-maximum-failures=5
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
/ip smb shares
set [ find default=yes ] directory=/pub
/ip traffic-flow
set enabled=yes interfaces=ether8
/ip traffic-flow target
add dst-address=192.168.10.5 port=4739
/ipv6 address
add address=::1 from-pool=ipv6pool interface=BR1
/ipv6 dhcp-client
add add-default-route=yes interface=ether8 pool-name=ipv6pool \
    pool-prefix-length=60 request=address,prefix
/ipv6 firewall filter
add action=drop chain=input comment="Drop (invalid)" connection-state=invalid
add action=accept chain=input comment="Accept (established, related)" \
    connection-state=established,related
add action=accept chain=input comment="Accept DHCP (10/sec)" in-interface=\
    ether8 limit=10,20:packet protocol=udp src-port=547
add action=drop chain=input comment="Drop DHCP (>10/sec)" in-interface=ether8 \
    protocol=udp src-port=547
add action=accept chain=input comment="Accept external ICMP (10/sec)" \
    in-interface=ether8 limit=10,20:packet protocol=icmpv6
add action=drop chain=input comment="Drop external ICMP (>10/sec)" \
    in-interface=ether8 protocol=icmpv6
add action=accept chain=input comment="Accept internal ICMP" in-interface=\
    !ether8 protocol=icmpv6
add action=drop chain=input comment="Drop external" in-interface=ether8
add action=reject chain=input comment="Reject everything else"
add action=accept chain=output comment="Accept all"
add action=drop chain=forward comment="Drop (invalid)" connection-state=\
    invalid
add action=accept chain=forward comment="Accept (established, related)" \
    connection-state=established,related
add action=accept chain=forward comment="Accept external ICMP (20/sec)" \
    in-interface=ether8 limit=20,50:packet protocol=icmpv6
add action=drop chain=forward comment="Drop external ICMP (>20/sec)" \
    in-interface=ether8 protocol=icmpv6
add action=accept chain=forward comment="Accept internal" in-interface=\
    !ether8
add action=accept chain=forward comment="Accept outgoing" out-interface=\
    ether8
add action=drop chain=forward comment="Drop external" in-interface=ether8
add action=reject chain=forward comment="Reject everything else"
/ipv6 nd
set [ find default=yes ] advertise-dns=no
/system clock
set time-zone-name=America/Chicago
/system identity
set name=router.ezit.me
/system logging
set 0 action=splunk
set 1 action=splunk
set 2 action=splunk
set 3 action=splunk
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp server
set enabled=yes
/system ntp client servers
add address=129.6.15.29
add address=129.6.15.28
/tool e-mail
set server=192.168.10.10
