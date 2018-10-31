#!/bin/bash
# clearlog.sh
# Clear debug.log every other day
# Add the following to the crontab (i.e. crontab -e)
# 0 0 */2 * * ~/swiftnode/clearlog.sh

/bin/date > ~/.swiftcash/debug.log
