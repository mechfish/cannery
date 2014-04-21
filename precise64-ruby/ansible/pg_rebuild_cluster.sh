#!/bin/sh
# check for UTF8 in the encoding field (column 3 ) of the template1 database info
sudo -u postgres psql -l | grep template1 | cut -f3 -d'|' | grep -q UTF8
# If UTF8 is not present then drop and recreate the cluster with the correct locale
if [ $? -ne 0 ]; then
    pg_dropcluster --stop 9.1 main
    pg_createcluster --locale=en_US.UTF-8 9.1 main
    service postgresql start
fi
