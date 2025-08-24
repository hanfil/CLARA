#!/bin/vbash
source /opt/vyatta/etc/functions/script-template
configure
delete container name elasticsearch
delete container name kibana
delete container name fleet
delete container network elastic
show | grep "- "
commit
exit