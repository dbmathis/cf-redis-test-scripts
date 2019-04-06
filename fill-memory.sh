#!/bin/sh
# Use example app restful API to test different scenarios with redis instances
# 
# Info of interest
#
# curl -sX GET $APP/info/memory/used_memory                                                                                                                                              # curl -sX GET $APP/info/memory/maxmemory
# curl -sX GET $APP/info/stats/evicted_keys

export APP=redis-example-app.cfapps-17.haas-59.pez.pivotal.io

# Define globals
REDISMAXMEMHUMAN=$(curl -sX GET $APP/info/memory/maxmemory_human)
REDISMAXMEM=$(curl -sX GET $APP/info/memory/maxmemory)
REDISUSEDMEMHUMAN=$(curl -sX GET $APP/info/memory/used_memory_human)
REDISUSEDMEM=$(curl -sX GET $APP/info/memory/used_memory)
CURDIR=${PWD} 
value=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 10000 | xargs)

echo 'SET foo bar' > "${CURDIR}/data.txt"

while [ $(wc -c < "${CURDIR}/data.txt") -le $REDISMAXMEM ]; do
   key=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 12 | xargs)

   echo "SET ${key} ${value}"  >> "${CURDIR}/data.txt"
   #echo $(wc -c < "${CURDIR}/data.txt")
   
   #curl -X PUT "${APP}/${key}" -d "data=${value}"

   #echo ''

   #REDISUSEDMEM=$(curl -sX GET $APP/info/memory/used_memory)
   #REDISUSEDMEM=$(curl -sX GET $APP/info/memory/used_memory_human)
   #echo "Used:   ${REDISUSEDMEM}"
   #echo "Max:    ${REDISM"
done

cat "${CURDIR}/data.txt" | redis-cli -h 10.193.82.145 -a 'MBAreVyrigEBTMcFq06kyxVRTD0=' --pipe

