#!/bin/bash
# Generate certificate with all device IPs

# Get all non-loopback IP addresses
IPS=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1)

# Start building the SAN string
SAN="DNS:localhost,IP:127.0.0.1"
for ip in $IPS; do
    SAN="$SAN,IP:$ip"
done

echo "Creating certificate with SAN: $SAN"

# Generate certificate
openssl req -nodes -x509 -sha256 -newkey rsa:4096 \
  -keyout localhost.key \
  -out localhost.crt \
  -days 365 \
  -subj "/C=US/ST=State/L=City/O=Organization/OU=IT/CN=localhost" \
  -addext "subjectAltName = $SAN"

echo "Certificate created: localhost.crt"
echo "Private key created: localhost.key"

# Verify the certificate
echo -e "\nCertificate details:"
openssl x509 -in localhost.crt -text -noout | grep -A 10 "Subject Alternative Name"


# Enabling TLS for kibana
echo "Enabling TLS for Kibana"
sudo cp /opt/clara/elastic/localhost.crt /opt/kibana/config/kibana.crt
sudo cp /opt/clara/elastic/localhost.key /opt/kibana/config/kibana.key
sudo chown 1000:0 /opt/kibana/config/kibana.crt
sudo chown 1000:0 /opt/kibana/config/kibana.key

cat >> /opt/kibana/config/kibana.yml << EOF
server.ssl.enabled: true
server.ssl.certificate: config/kibana.crt
server.ssl.key: config/kibana.key
EOF