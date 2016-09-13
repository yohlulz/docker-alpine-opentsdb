#!/bin/sh

CACHE_CLEAN_INTERVAL=${CACHE_CLEAN_INTERVAL:-600}
CACHE_MAX_AGE_MINUTES=${CACHE_MAX_AGE_MINUTES:-720}
TSD_HOST=${TSD_HOST:-"127.0.0.1"}
TSD_PORT=${TSD_PORT:-"4242"}

echo "Waiting for TSD to start..."
sleep "${CACHE_CLEAN_INTERVAL}"

CACHE_DIR=`curl -sS "http://${TSD_HOST}:${TSD_PORT}/api/config" | jq -c  "[{\"tsd.http.cachedir\"}]" | cut -d \" -f 4 | tr -d " "`

# Clean TSD cache
# Remove files older than 12h every 10m
echo "[$(date)] Cleaning cache ..."
while true; do
	if [ ! -d "${CACHE_DIR}" ];then
		exit 1
	fi
	case "$CACHE_DIR" in
	*cache*)
		find ${CACHE_DIR} -mindepth 1 -mmin "+${CACHE_MAX_AGE_MINUTES}" -delete;
		echo "[$(date)] "`du -lh ${CACHE_DIR}`
		sleep "${CACHE_CLEAN_INTERVAL}"
	esac
done

