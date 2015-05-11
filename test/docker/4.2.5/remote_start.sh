#!/bin/sh
service zenoss start &
service mysql start &
service rabbitmq-server start
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl start_app
rabbitmqctl add_vhost "/zenoss"
rabbitmqctl add_user zenoss \
            "$(sed -n 's/amqppassword \(.*\)/\1/p' /opt/zenoss/etc/global.conf)"
rabbitmqctl set_permissions -p "/zenoss" zenoss ".*" ".*" ".*"
tail -F /opt/zenoss/log/event.log
