#!/bin/bash
# makerun.sh
# Make sure swiftcashd is always running.
# Add the following to the crontab (i.e. crontab -e)
# */5 * * * * ~/swiftnode/makerun.sh

if ! ps -A | grep swiftcashd > /dev/null
else
  swiftcashd &
fi

if ! ps -Af | grep cpulimit | grep swiftcashd > /dev/null
then
  cpulimit -P /usr/bin/swiftcashd -l 50
fi
