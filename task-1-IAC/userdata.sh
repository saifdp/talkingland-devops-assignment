#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo echo "Deployed via Terraform." > /usr/share/nginx/html/index.html