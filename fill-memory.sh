#!/bin/sh
# Use example app restful API to test different scenarios with redis instances

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
api=
host=
password=
verbose=0

# Define usage
function usage {
    cat <<EOM
Usage: 
 
  $(basename "$0") -a <api> -h <host> -p <password>
      
  -a|--api       <text> redis api app url/ip 
  -h|--host      <text> redis server url/ip
  -p|--pawword   <text> redis server password
redis-example-app.cfapps-17.haas-59.pez.pivotal.io 
  -h|--help                   
Examples:
  $ $(basename "$0") -a redis-example-app.cfapps-17.haas-59.pez.pivotal.io -h 1.2.3.4 -p <password> 
EOM
    exit 2
}

# Process options
while :; do
    case $1 in
        -\?|--help)
            usage           # Display a usage synopsis.
            exit
            ;;
        -h|--host)               # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                host=$2
                shift
            else
                die 'ERROR: "--host" requires a non-empty option argument.'
            fi
            ;;
        --host=?*)
            host=${1#*=}         # Delete everything up to "=" and assign the remainder.
            ;;
        --host=)                 # Handle the case of an empty --host=
            die 'ERROR: "--host" requires a non-empty option argument.'
            ;;
        -p|--password)           # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                password=$2
                shift
            else
                die 'ERROR: "--password" requires a non-empty option argument.'
            fi
            ;;
        --password=?*)
            password=${1#*=}     # Delete everything up to "=" and assign the remainder.
            ;;
        --password=)             # Handle the case of an empty --password=
            die 'ERROR: "--password" requires a non-empty option argument.'
            ;;
        -a|--api)                # Takes an option argument; ensure it has been specified.
            if [ "$2" ]; then
                api=$2
                shift
            else
                die 'ERROR: "--api" requires a non-empty option argument.'
            fi
            ;;
        --api=?*)
            api=${1#*=}          # Delete everything up to "=" and assign the remainder.
            ;;
        --api=)                  # Handle the case of an empty --api=
            die 'ERROR: "--host" requires a non-empty option argument.'
            ;;
       -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
            ;;
        --)                      # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)                       # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

export APP=$api

CURDIR=${PWD} # Current dir 
VALUE=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 60000 | xargs) # Value string (max 60K)
REDISMAXMEM=$(curl -sX GET $APP/info/memory/maxmemory) # Redis max memory

while [ $(wc -c < "${CURDIR}/data.txt") -le $REDISMAXMEM ]; do
   KEY=$(LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | head -c 12 | xargs)

   echo "SET ${KEY} ${VALUE}" >> "${CURDIR}/data.txt"
   #echo $(wc -c < "${CURDIR}/data.txt")
done

cat "${CURDIR}/data.txt" | redis-cli -h $host -a $password --pipe
