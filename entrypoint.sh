#!/bin/sh

#set -e

rm -f /run/dbus/pid
rm -f /var/run/avahi-daemon/pid
mkdir -p /run/dbus

dbus-uuidgen --ensure
dbus-daemon --system

avahi-daemon --daemonize

snapserver
