#!/bin/bash
TSD_HOST=${TSD_HOST:-"127.0.0.1"}
TSD_PORT=${TSD_PORT:-"4242"}
REFRESH_INTERVAL=${REFRESH_INTERVAL:-60}

echo "Waiting for TSD to start..."
sleep "${REFRESH_INTERVAL}"

TSD_CONFIG=`curl --max-time 5 -sS "http://${TSD_HOST}:${TSD_PORT}/api/config"`
TSD_MODE=`echo ${TSD_CONFIG} | jq -c  "[{\"tsd.mode\"}]" | cut -d \" -f 4 | tr -d " "`
CHUNK_ENABLED=`echo ${TSD_CONFIG} | jq -c  "[{\"tsd.http.request.enable_chunked\"}]" | cut -d \" -f 4 | tr -d " "`

if [ "${TSD_MODE}" != "rw" ]; then
	echo "Read only mode (tsd.mode), aborting..."
	exit 1
fi
if [ "${CHUNK_ENABLED}" != "true" ]; then
	echo "Chunk mode not enabled (tsd.http.request.enable_chunked), aborting..."
	exit 1
fi

# Feeding opentsdb metrics back to itself each minute
if [ "${REFRESH_INTERVAL:-60}" != "0" ]; then
    while true; do
        echo "[$(date)] Writing stats ..."
	curl --max-time 5 -s "http://${TSD_HOST}:${TSD_PORT}/api/stats" | curl --max-time 5 -s -X POST -H "Content-type: application/json" "http://${TSD_HOST}:${TSD_PORT}/api/put" -d @-
        sleep "${REFRESH_INTERVAL}"
    done
fi

