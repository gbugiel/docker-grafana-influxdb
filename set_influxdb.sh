#!/bin/bash

set -m
CONFIG_FILE="/etc/influxdb/config.toml"

INFLUX_HOST="localhost"
INFLUX_API_PORT="8086"
API_URL="http://${INFLUX_HOST}:${INFLUX_API_PORT}"

sed -i "s/^max-open-shards.*/max-open-shards = $(ulimit -n)/" ${CONFIG_FILE}

echo "=> About to create the following database: ${PRE_CREATE_DB}"
if [ -f "/.influxdb_configured" ]; then
    echo "=> Database had been created before, skipping ..."
else
    echo "=> Starting InfluxDB ..."
    exec influxd -config=${CONFIG_FILE} &
    arr=$(echo ${PRE_CREATE_DB} | tr ";" "\n")

    RET=1
    while [[ RET -ne 0 ]]; do
        echo "=> Waiting for confirmation of InfluxDB service startup ..."
        sleep 3
        curl -k ${API_URL}/ping 2> /dev/null
        RET=$?
    done
    echo ""

    echo "=> Creating admin user"
    influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -execute="CREATE USER ${INFLUXDB_ADMIN_USER} WITH PASSWORD '${INFLUXDB_ADMIN_PW}' WITH ALL PRIVILEGES"
    for x in $arr
    do
        echo "=> Creating database: ${x}"
        influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${INFLUXDB_ADMIN_USER} -password="${INFLUXDB_ADMIN_PW}" -execute="create database ${x}"
        influx -host=${INFLUX_HOST} -port=${INFLUX_API_PORT} -username=${INFLUXDB_ADMIN_USER} -password="${INFLUXDB_ADMIN_PW}" -execute="grant all PRIVILEGES on ${x} to ${INFLUXDB_ADMIN_USER}"
    done
    echo ""

    touch "/.influxdb_configured"
    exit 0
fi

exit 0
