#!/usr/bin/env bash

cd /usr/src
sudo mv geoevents geoevents.github
sudo ln -s /vagrant/geoevents-repo geoevents
sudo source /vagrant/scripts/restart_web_server.sh