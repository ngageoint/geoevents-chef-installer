#!/usr/bin/env bash

sudo service nginx restart
sudo killall -9 uwsgi
sudo /var/lib/geoevents/bin/uwsgi --ini /var/lib/geoevents/geoevents.ini --py-auto-reload=3 &
echo "Nginx and uWSGI should have restarted"