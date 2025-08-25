# Download repository
```bash
git clone https://github.com/hanfil/CLARA.git
```

# INSTALLATION
Change into directory and run install.sh with root privileges



# INFO
sudo apt-mark manual vyos-1x
This should be installed on VyOS 1.5 (which is based on debian 12 - Bookworm)



# NETFLOW TROUBLESHOOTING
There may be issues where egress traffic is not correctly enabled.
Look at the "nft list ruleset" under _inet mangle_ there is two chains FORWARD and OUTPUT.
If you're missing OUTPUT then that is the issue.

## 1) Create the OUTPUT chain if it doesn’t exist yet
sudo nft add chain inet mangle OUTPUT '{ type filter hook output priority mangle; policy accept; }'

## 2) Add your egress rules (for lo and other interfaces) matching what VyOS would have installed
sudo nft add rule inet mangle OUTPUT oifname "lo" counter packets 0 bytes 0 log group 2 snaplen 128 queue-threshold 100 comment "FLOW_ACCOUNTING_RULE"
