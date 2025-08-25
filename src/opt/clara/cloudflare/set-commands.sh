#!/bin/vbash
# Include VyOS function calls
source /opt/vyatta/etc/functions/script-template
configure

set container name cloudflared command 'tunnel run'
set container name cloudflared environment TUNNEL_TOKEN value 'eyJhIjoiZjJjY2Y5OTE2YzY5YTQ4ZGQ5NGYxYTEyZDlkNmYzZjkiLCJ0IjoiMzY3ZWViN2UtYjRiNS00MTZiLWJkZDItMWUxMzFlODdkNTQ3IiwicyI6Ik1EazBaR0prWldNdFpUQTRaQzAwWWpRekxUbGtaVGd0T1dKa09ESTNNelE0WmpFeCJ9'
set container name cloudflared image 'cloudflare/cloudflared:latest'
set container name cloudflared network cloudflared

set network cloudflared prefix '10.199.2.0/24'

set nat source rule 2 description 'Container network NAT - Cloudflare Tunnel'
set nat source rule 2 outbound-interface name 'wlan0'
set nat source rule 2 source address '10.199.2.0/24'
set nat source rule 2 translation address 'masquerade'