#!/bin/bash

TSD_MODE=${TSD_MODE:-"ro"}
TSD_CMD=${TSD_CMD:-"/opt/opentsdb/bin/tsdb"}
TSD_ACTION=${TSD_ACTION:-"tsd"}
TSD_CONF=${TSD_CONF:-"/opt/data/tsdb/opentsdb_${TSD_MODE}.conf"}

function stop_tsdb {
	echo "stopping tsdb..."
	pgrep -f TSDMain | xargs kill -9
	exit
}
trap stop_tsdb HUP INT TERM EXIT SIGHUP SIGINT SIGTERM

echo "starting tsdb...(${TSD_MODE})"
exec "$TSD_CMD" ${TSD_ACTION} --config ${TSD_CONF}
