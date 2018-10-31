#!/bin/bash
# upgrade.sh
# Make sure swiftcash is up-to-date
# Add the following to the crontab (i.e. crontab -e)
# 0 0 */1 * * ~/swiftnode/upgrade.sh

# apt update

# if apt list --upgradable | grep -v grep | grep swiftcashd > /dev/null
# then
  # swiftcash-cli stop && sleep 10
  # rm ~/.swiftcash/peers.*
  # apt install swiftcashd -y && swiftcashd&
# else
  # exit
# fi
