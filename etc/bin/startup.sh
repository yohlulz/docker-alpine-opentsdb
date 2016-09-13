#!/bin/bash

chown -R root:root /etc/supervisord.d/*
chown root:root /etc/supervisord.conf
chown -R root:root /opt/opentsdb/bin/*


alias supervisorctl="/usr/bin/supervisorctl -c /etc/supervisord.conf"

supervisord -c /etc/supervisord.conf
