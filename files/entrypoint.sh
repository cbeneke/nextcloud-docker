#!/bin/sh
set -e

[ ! -d /var/run/apache2 ] && mkdir -p /var/run/apache2
[ ! -d /var/lock/apache2 ] && mkdir -p /var/lock/apache2

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

# ssl_scache shouldn't be here if we're just starting up.
# (this is bad if there are several apache2 instances running)
rm -f /var/run/apache2/*ssl_scache*

export APACHE_ARGUMENTS="-D FOREGROUND"
exec /usr/sbin/apachectl start
