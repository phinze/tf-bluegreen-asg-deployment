#!/bin/bash
sudo apt-get install -y apache2
echo "Hello world" | sudo tee /var/www/html/index.html
cat /var/lib/cloud/data/instance-id | sudo tee -a /var/www/html/index.html
