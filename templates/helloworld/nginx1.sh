#!/bin/bash

sudo apt-get update && sudo apt-get -y install nginx
sudo sh -c 'echo "<html><h1>Hello World</h1></html>" > /var/www/html/index.html'

