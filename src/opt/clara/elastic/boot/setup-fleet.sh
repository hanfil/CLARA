#!/bin/bash
echo "Waiting for enrollment token..."
while [ ! -f enrollment/fleet_enrollment.env ]; do
  echo "Waiting for enrollment token..."
  sleep 10
done
source enrollment/fleet_enrollment.env
export FLEET_SERVER_SERVICE_TOKEN
env
/usr/local/bin/docker-entrypoint