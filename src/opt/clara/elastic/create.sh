#!/bin/vbash
sudo mkdir /opt/elastic
sudo chown vyos /opt/elastic
mkdir /opt/elastic/config
mkdir /opt/elastic/data
mkdir /opt/elastic/logs
mkdir /opt/elastic/plugins
mkdir /opt/elastic/enrollment
mkdir /opt/elastic/config/certs

touch /opt/elastic/config/jvm.options
touch /opt/elastic/config/elasticsearch.yml
touch /opt/elastic/config/log4j2.properties
touch /opt/elastic/config/users
touch /opt/elastic/config/users_roles

sudo mkdir /opt/kibana
sudo chown vyos /opt/kibana
mkdir /opt/kibana/config
mkdir /opt/kibana/data
mkdir /opt/kibana/logs
mkdir /opt/kibana/plugins
touch /opt/kibana/config/kibana.yml

sudo chown 1000:0 -R /opt/elastic # Service user inside the container runs as uid 1000
sudo chown 1000:0 -R /opt/kibana # Service user inside the container runs as uid 1000

sudo chmod +x /opt/clara/elastic/boot/*.sh

# Include VyOS function calls
source /opt/vyatta/etc/functions/script-template
configure

# Add containers
echo "Downloading container images..."
run add container image docker.elastic.co/elasticsearch/elasticsearch:9.1.2
run add container image docker.elastic.co/kibana/kibana:9.1.2
run add container image docker.elastic.co/elastic-agent/elastic-agent:9.1.2

# Configure vyos config
merge /opt/clara/elastic/configuration
show | grep "+ "
commit
exit