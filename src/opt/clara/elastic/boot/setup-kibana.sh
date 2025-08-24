#!/bin/bash
KIBANA_CONFIG=/usr/share/kibana/config/kibana.yml
if ! grep -q "server.host" $KIBANA_CONFIG; then
echo "server.host: \"0.0.0.0\"" >> $KIBANA_CONFIG
fi
if ! grep -q "server.shutdownTimeout" $KIBANA_CONFIG; then
echo "server.shutdownTimeout: \"5s\"" >> $KIBANA_CONFIG
fi
if ! grep -q "monitoring.ui.container.elasticsearch.enabled" $KIBANA_CONFIG; then
echo "monitoring.ui.container.elasticsearch.enabled: true" >> $KIBANA_CONFIG
fi
if ! grep -q "telemetry.enabled" $KIBANA_CONFIG; then
echo "telemetry.enabled: false" >> $KIBANA_CONFIG
fi
if ! grep -q "xpack.encryptedSavedObjects.encryptionKey" $KIBANA_CONFIG; then
ENCRYPTIONKEY=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 32; echo)
echo "xpack.encryptedSavedObjects.encryptionKey: $ENCRYPTIONKEY" >> $KIBANA_CONFIG
fi
if ! grep -q "xpack.fleet.packages" $KIBANA_CONFIG; then
cat >> $KIBANA_CONFIG << EOF
xpack.fleet.packages:
  - name: suricata
    version: latest
  - name: zeek
    version: latest
  - name: netflow
    version: latest
xpack.fleet.agentPolicies:
  - id: fleet-server-policy
    name: Fleet Server Policy
    package_policies:
      - id: netflow-records
        package:
          name: netflow
        name: NetFlow Records
      - id: suricata
        package:
          name: suricata
        name: Suricata
      - id: zeek
        package:
          name: zeek
        name: Zeek
EOF
fi

if ! grep -q "elasticsearch.serviceAccountToken:" $KIBANA_CONFIG; then
echo "Waiting for enrollment token..."
while [ ! -f /usr/share/kibana/enrollment/kibana_enrollment.env ]; do
  sleep 2
done
echo "Loading enrollment token..."
source /usr/share/kibana/enrollment/kibana_enrollment.env
echo "Installing enrollment token..."
export KIBANA_ENROLLMENT_TOKEN
/usr/share/kibana/bin/kibana-setup -t $KIBANA_ENROLLMENT_TOKEN
env
fi

echo "----CONTENT OF KIBANA.YML:----"
cat $KIBANA_CONFIG
echo "------------------------------"

echo "Starting kibana"
/usr/local/bin/kibana-docker