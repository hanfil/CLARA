#!/bin/vbash
source /opt/vyatta/etc/functions/script-template
configure
merge /opt/clara/elastic/configuration
show | grep "+ "
commit
exit