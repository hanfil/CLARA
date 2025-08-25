#!/bin/bash

# REMOVE CONFIGURATION
echo "Removing containers..."
/opt/clara/elastic/remove.sh

sleep 2

# CLEANUP FOLDERS
echo "Recreating folder structure..."
sudo rm -r /opt/elastic
sudo rm -r /opt/kibana

sleep 2

# CREATE CONFIGURATION
echo "Creating containers..."
/opt/clara/elastic/create.sh