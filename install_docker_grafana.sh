#!/bin/bash


sudo yum update -y
sudo yum install -y docker
sudo usermod -aG docker ec2-user
sudo service docker start
sudo chkconfig docker on
sudo docker run -d  --name grafana  -p 3000:3000  grafana/grafana

