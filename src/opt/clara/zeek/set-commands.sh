#!/bin/vbash
# Include VyOS function calls
source /opt/vyatta/etc/functions/script-template

add container image zeek/zeek:latest

configure
# Configure the Zeek container
set container name zeek image 'zeek/zeek:latest'
set container name zeek memory '2048'
set container name zeek command "zeek -C -i nfqueue:0 /config/zeek/scripts/local.zeek 2>/dev/null"

# Network configuration for nfqueue access
set container name zeek allow-host-networks

# Essential capabilities for nfqueue and network monitoring
set container name zeek capability 'net-admin'
set container name zeek capability 'net-raw'
set container name zeek capability 'net-bind-service'

# Mount volumes with same source and destination paths as requested
set container name zeek volume logs source '/opt/zeek/logs'
set container name zeek volume logs destination '/opt/zeek/logs'
set container name zeek volume scripts source '/opt/zeek/scripts'  
set container name zeek volume scripts destination '/opt/zeek/scripts'

# Forward to queue 0
set firewall ipv4 name ZEEK_MONITOR rule 10 action 'queue'
set firewall ipv4 name ZEEK_MONITOR rule 10 queue 0
set firewall ipv4 name ZEEK_MONITOR rule 10 queue-options bypass
set firewall ipv4 name ZEEK_MONITOR rule 10 protocol 'all'

# Apply to interface for forwarded traffic
set firewall ipv4 forward filter rule 100 action 'jump'
set firewall ipv4 forward filter rule 100 jump-target 'ZEEK_MONITOR'
set firewall ipv4 forward filter rule 100 inbound-interface name 'wlan0'

