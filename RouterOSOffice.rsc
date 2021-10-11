# OFFICE Router with VLAN and L2TP VPN Server
#
# oct/10/2021 21:39:47 by RouterOS 6.47.10
#
# model = RB4011iGS+
# serial number = XXXXXXXXX
/interface bridge
add name=MAIN_BR1 protocol-mode=none vlan-filtering=yes
/interface ethernet
set [ find default-name=sfp-sfpplus1 ] disabled=yes
/interface vlan
add interface=MAIN_BR1 name=GUEST_VLAN vlan-id=20
add interface=MAIN_BR1 name=PUBVM_VLAN vlan-id=8
add interface=MAIN_BR1 name=VOIP_VLAN vlan-id=30
/interface ethernet switch port
set 0 default-vlan-id=0
set 1 default-vlan-id=0
set 2 default-vlan-id=0
set 3 default-vlan-id=0
set 4 default-vlan-id=0
set 5 default-vlan-id=0
set 6 default-vlan-id=0
set 7 default-vlan-id=0
set 8 default-vlan-id=0
set 9 default-vlan-id=0
set 10 default-vlan-id=0
set 11 default-vlan-id=0
/interface list
add name=WAN
add name=IVLAN
add name=EVLAN
add name=LAN
/ip pool
add name=MAIN_POOL ranges=10.160.180.80-10.160.180.250
add name=PUBVM_POOL ranges=192.168.8.100-192.168.8.199
add name=GUEST_POOL ranges=192.168.20.100-192.168.20.199
add name=VOIP_POOL ranges=192.168.30.100-192.168.30.199
add name=MAIN_VPN_POOL ranges=192.168.9.10-192.168.9.126
add name=PUBVM_VPN_POOL ranges=192.168.9.130-192.168.9.254
/ip dhcp-server
add address-pool=MAIN_POOL disabled=no interface=MAIN_BR1 name=MAIN_DHCP
add address-pool=PUBVM_POOL disabled=no interface=PUBVM_VLAN name=PUBVM_DHCP
add address-pool=GUEST_POOL disabled=no interface=GUEST_VLAN name=GUEST_DHCP
add address-pool=VOIP_POOL disabled=no interface=VOIP_VLAN name=VOIP_DHCP
/ppp profile
add dns-server=10.160.180.20,10.160.180.19 local-address=192.168.8.1 name=\
    PUBVM_VPN_Profile remote-address=PUBVM_VPN_POOL
add dns-server=10.160.180.20,10.160.180.19 local-address=10.160.180.1 name=\
    MIAN_VPN_Profile remote-address=MAIN_VPN_POOL
/queue simple
add burst-limit=3M/30M burst-threshold=1M/10M burst-time=30s/30s max-limit=\
    1M/10M name=GUEST_BANDWIDTH target=GUEST_VLAN
/interface bridge port
add bridge=MAIN_BR1 ingress-filtering=yes interface=ether2
add bridge=MAIN_BR1 ingress-filtering=yes interface=ether3
add bridge=MAIN_BR1 ingress-filtering=yes interface=ether10
add bridge=MAIN_BR1 interface=ether4 pvid=8
add bridge=MAIN_BR1 interface=ether5 pvid=8
add bridge=MAIN_BR1 interface=ether6 pvid=30
add bridge=MAIN_BR1 interface=ether7 pvid=30
add bridge=MAIN_BR1 ingress-filtering=yes interface=ether8
add bridge=MAIN_BR1 ingress-filtering=yes interface=ether9
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface bridge vlan
add bridge=MAIN_BR1 tagged=ether8,ether9,ether10,MAIN_BR1 untagged=\
    ether4,ether5 vlan-ids=8
add bridge=MAIN_BR1 tagged=ether8,ether9,ether10,MAIN_BR1 vlan-ids=20
add bridge=MAIN_BR1 tagged=ether2,ether3,MAIN_BR1 untagged=ether6,ether7 \
    vlan-ids=30
/interface l2tp-server server
set authentication=mschap2 default-profile=PUBVM_VPN_Profile enabled=yes \
    ipsec-secret=SECRETKEY use-ipsec=yes
/interface list member
add interface=ether1 list=WAN
add interface=GUEST_VLAN list=EVLAN
add interface=VOIP_VLAN list=EVLAN
add interface=PUBVM_VLAN list=IVLAN
add interface=MAIN_BR1 list=LAN
/ip address
add address=10.160.180.1/24 interface=MAIN_BR1 network=10.160.180.0
add address=192.168.8.1/24 interface=PUBVM_VLAN network=192.168.8.0
add address=192.168.20.1/24 interface=GUEST_VLAN network=192.168.20.0
add address=192.168.30.1/24 interface=VOIP_VLAN network=192.168.30.0
add address=STATIC_IP_ADDRESS/29 interface=ether1 network=STATIC_IP_NETWORK
/ip dhcp-client
add interface=ether1
/ip dhcp-server network
add address=10.160.180.0/24 dns-server=10.160.180.19,10.160.180.20 domain=\
    EXAMPLE.COM gateway=10.160.180.1 netmask=24 ntp-server=10.160.180.1
add address=192.168.8.0/24 dns-server=10.160.180.19,10.160.180.20 domain=\
    EXAMPLE.COM gateway=192.168.8.1 netmask=24 ntp-server=10.160.180.1
add address=192.168.20.0/24 dns-server=8.8.8.8,8.8.4.4 gateway=192.168.20.1 \
    netmask=24
add address=192.168.30.0/24 dns-server=8.8.8.8,8.8.4.4 gateway=192.168.30.1 \
    netmask=24
/ip dns
set allow-remote-requests=yes servers=10.160.180.19,10.160.180.20,8.8.8.8
/ip firewall address-list
add address=10.160.180.0/24 list=Main_Lan_addresses
add address=192.168.8.0/24 list=PUBVMs_Addresses
add address=192.168.20.0/24 list=Guest_Addresses
add address=192.168.30.0/24 list=VOIP_Addresses
add address=192.168.9.0/24 list=VPN_Addresses
add address=192.168.9.0/25 list=Full_Access_VPN_Address
add address=192.168.9.128/25 list=PUBVM_VPN_Addresses
/ip firewall filter
add action=accept chain=input comment="Allow Estab & Related" \
    connection-state=established,related
add action=accept chain=input comment="Allow inputs from all Addresses" \
    src-address-list=PUBVMs_Addresses
add action=accept chain=input src-address-list=Main_Lan_addresses
add action=accept chain=input src-address-list=VOIP_Addresses
add action=accept chain=input src-address-list=Guest_Addresses
add action=accept chain=input src-address-list=Full_Access_VPN_Address
add action=accept chain=input comment="Allow L2TP VPN" port=1701,500,4500 \
    protocol=udp
add action=accept chain=input protocol=ipsec-esp
add action=drop chain=input comment="Drop other inputs"
add action=accept chain=forward comment="Allow Estab & Related forwards" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "Allow Main Lan to Access PUBVMs, VOIP" dst-address-list=PUBVMs_Addresses \
    src-address-list=Main_Lan_addresses
add action=accept chain=forward dst-address-list=VOIP_Addresses \
    src-address-list=Main_Lan_addresses
add action=accept chain=forward comment="#allow DNS query" dst-address-list=\
    Main_Lan_addresses dst-port=53 protocol=tcp src-address-list=\
    PUBVMs_Addresses
add action=accept chain=forward dst-address-list=Main_Lan_addresses dst-port=\
    53 protocol=udp src-address-list=PUBVMs_Addresses
add action=accept chain=forward dst-address-list=Main_Lan_addresses dst-port=\
    53 protocol=tcp src-address-list=VPN_Addresses
add action=accept chain=forward dst-address-list=Main_Lan_addresses dst-port=\
    53 protocol=udp src-address-list=VPN_Addresses
add action=accept chain=forward comment=\
    "Allow all VLAN to access unifi controller http ports" dst-address=\
    10.160.180.8 dst-port=8800-8999 in-interface=all-vlan protocol=tcp
add action=accept chain=forward comment="Allow All VLAN Access Internet" \
    connection-state=new in-interface=all-vlan out-interface-list=WAN
add action=accept chain=forward comment="All Lan full access" \
    in-interface-list=LAN out-interface-list=WAN
add action=accept chain=forward comment="VPN Users policies" \
    dst-address-list=Main_Lan_addresses src-address-list=\
    Full_Access_VPN_Address
add action=accept chain=forward dst-address-list=PUBVMs_Addresses \
    src-address-list=VPN_Addresses
add action=accept chain=forward out-interface-list=WAN src-address-list=\
    VPN_Addresses
add action=accept chain=forward comment="Allow WAN Ports forwarding" \
    connection-nat-state=dstnat connection-state=new in-interface-list=WAN
add action=drop chain=forward comment=Drop
/ip firewall nat
add action=masquerade chain=srcnat comment="Default masquerade" \
    out-interface-list=WAN
add action=dst-nat chain=dstnat comment="Open http port to WebVM" dst-port=80 \
    in-interface-list=WAN protocol=tcp to-addresses=192.168.8.11 to-ports=80
add action=dst-nat chain=dstnat comment=\
    "Allow ping dell server from Internet" in-interface-list=WAN protocol=\
    icmp to-addresses=10.160.180.10
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
add distance=1 gateway=GATEWAYIP pref-src=STATICIP
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www address=10.160.180.0/24,192.168.9.0/25
set ssh address=10.160.180.0/24,192.168.9.0/25
set api disabled=yes
set winbox address=10.160.180.0/24,192.168.9.0/25
set api-ssl disabled=yes
/ppp secret
add name=USERNAME password=PASSWORD profile=MIAN_VPN_Profile service=l2tp
/system clock
set time-zone-name=America/Chicago
/system identity
set name=OFFICERouter
/system leds
set 0 disabled=yes
/system ntp client
set enabled=yes primary-ntp=129.6.15.28 secondary-ntp=129.6.15.29 \
    server-dns-names=time.nist.gov
/system ntp server
set enabled=yes
/system package update
set channel=long-term
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN