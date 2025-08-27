#!/bin/vbash
# Include VyOS function calls
source /opt/vyatta/etc/functions/script-template

add container image jasonish/suricata:8.0.0


configure
set container name suricata image jasonish/suricata:8.0.0
set container name suricata memory '2048'
set container name suricata allow-host-networks
# It is required to set both IPS rules as exclusive and firewall rules as exclusive to load both
set container name suricata arguments "-q 1 --firewall --firewall-rules-exclusive=/etc/suricata/firewall/firewall.rules -S /var/lib/suricata/rules/suricata.rules"

set container name suricata capability 'net-admin'
set container name suricata capability 'net-raw'
set container name suricata capability 'net-bind-service'
set container name suricata capability 'sys-nice'

set container name suricata volume rules source /opt/suricata/rules
set container name suricata volume rules destination /var/lib/suricata/rules
set container name suricata volume config source /opt/suricata/config
set container name suricata volume config destination /etc/suricata
set container name suricata volume logs source /var/log/suricata
set container name suricata volume logs destination /var/log/suricata