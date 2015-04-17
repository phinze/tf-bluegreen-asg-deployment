#!/bin/bash

sudo apt-get install -y apache2

COLOR="blue"
INSTANCE_ID=$(cat /var/lib/cloud/data/instance-id)

echo "Hello world" | sudo tee /var/www/html/index.html
echo "Instance ID: ${INSTANCE_ID}" | sudo tee -a /var/www/html/index.html
echo "Color: ${COLOR}" | sudo tee -a /var/www/html/index.html
