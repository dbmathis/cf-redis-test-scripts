#!/bin/sh
# Use example app restful API to test different scenarios with redis instances
# 
# Info of interest
#
# curl -sX GET $APP/info/memory/used_memory                                                                                                                                              # curl -sX GET $APP/info/memory/maxmemory
# curl -sX GET $APP/info/stats/evicted_keys

export APP=redis-example-app.cfapps-17.haas-59.pez.pivotal.io

# Define globals
REDISMAXMEM=$(curl -sX GET $APP/info/memory/maxmemory)
REDISUSEDMEM=$(curl -sX GET $APP/info/memory/used_memory)

while [ $REDISUSEDMEM -le $REDISMAXMEM ]; do
   key=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 12 | xargs)
   value=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 250000 | xargs)

   curl -X PUT "${APP}/${key}" -d "data=${value}"

   echo ''

   REDISUSEDMEM=$(curl -sX GET $APP/info/memory/used_memory)
   echo "Used:   ${REDISUSEDMEM}"
   echo "Max:    ${REDISMAXMEM}"
done


