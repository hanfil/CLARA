
# Since NF_ACCEPT terminates the current base chain but allows "subsequently invoked base 
# chains" to process the packet, create two separate chains at different priorities:

 #!/bin/vbash
# /config/scripts/security-monitor-setup.sh
source /opt/vyatta/etc/functions/script-template
sleep 2

# Remove existing table
nft delete table inet clara_dpi 2>/dev/null || true

# Create table with two separate base chains
nft add table inet clara_dpi

# Chain 1: Zeek processing (priority -200, runs first)
nft add chain inet clara_dpi zeek_monitor { type filter hook forward priority -110\; policy accept\; }
nft add rule inet clara_dpi zeek_monitor counter queue num 0 bypass comment \"Zeek monitoring\"

# Chain 2: Suricata processing (priority -100, runs after Zeek's NF_ACCEPT)
nft add chain inet clara_dpi suricata_fw { type filter hook forward priority -100\; policy accept\; }
nft add rule inet clara_dpi suricata_fw counter queue num 1 bypass comment \"Suricata FW\"

logger "Security Monitor: Separate base chains configured"
