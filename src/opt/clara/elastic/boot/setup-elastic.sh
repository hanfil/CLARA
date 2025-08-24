#!/bin/bash
ELASTIC_PASSWORD_FILE=enrollment/elastic_password.env
export ELASTIC_PASSWORD_FILE

if  [ ! -f $ELASTIC_PASSWORD_FILE ]; then
echo "---- AUTOGENERATING ELASTICSEARCH PASSWORD ---- "
touch $ELASTIC_PASSWORD_FILE
echo $(tr -dc A-Za-z0-9 </dev/urandom | head -c 32) > $ELASTIC_PASSWORD_FILE
chmod 600 $ELASTIC_PASSWORD_FILE
fi
ELASTIC_PASSWORD=$(cat $ELASTIC_PASSWORD_FILE)
echo $ELASTIC_PASSWORD

# Start Elasticsearch in background
/usr/local/bin/docker-entrypoint.sh eswrapper &
ES_PID=$!

# Wait for elasticsearch to be ready
#until curl -s -k -u "elastic:$ELASTIC_PASSWORD" https://localhost:9200/_cluster/health; do
while [ $(curl -s -k -u "elastic:$ELASTIC_PASSWORD" https://localhost:9200/_cluster/health -o /dev/null -w '%{http_code}\n' -s) != "200" ]; do
  echo "Waiting for elasticsearch to start..."
  sleep 5
done

# Autogenerate passwords
#echo "---- AUTOGENERATING ELASTICSEARCH PASSWORD ---- "
#bin/elasticsearch-reset-password -u elastic -bs > enrollment/elastic_password.env
#ELASTIC_PASSWORD=$(cat enrollment/elastic_password.env)
#echo $ELASTIC_PASSWORD
#echo "ELASTIC_PASSWORD=$ELASTIC_PASSWORD" > enrollment/elastic_password.env

# Create kibana enrollment token and save it
echo "---- GENERATING KIBANA ENROLLMENT TOKEN ----"
TOKEN=$(bin/elasticsearch-create-enrollment-token -s kibana)
echo "KIBANA_ENROLLMENT_TOKEN=$TOKEN" > enrollment/kibana_enrollment.env
echo $TOKEN


# Create fleet enrollment
echo "---- GENERATING FLEET ENROLLMENT SERVICE TOKEN ----"
curl -k -u "elastic:$ELASTIC_PASSWORD" -XDELETE "https://localhost:9200/_security/service/elastic/fleet-server/credential/token/clara-fw"
FLEET_SERVICE_TOKEN_RAW=$(curl -k -u "elastic:$ELASTIC_PASSWORD" -XPOST "https://localhost:9200/_security/service/elastic/fleet-server/credential/token/clara-fw")
FLEET_SERVICE_TOKEN=$(echo $FLEET_SERVICE_TOKEN_RAW | cut -d '"' -f12)
echo "FLEET_SERVICE_TOKEN_RAW=$FLEET_SERVICE_TOKEN_RAW" > enrollment/fleet_enrollment.env
echo "FLEET_SERVER_SERVICE_TOKEN=$FLEET_SERVICE_TOKEN" >> enrollment/fleet_enrollment.env

# Keep Elasticsearch running
wait $ES_PID