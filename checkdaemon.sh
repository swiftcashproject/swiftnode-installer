#!/bin/bash
# checkdaemon.sh
# Make sure the daemon is not stuck.
# Add the following to the crontab (i.e. crontab -e)
# */120 * * * * ~/swiftnode/checkdaemon.sh

previousBlock=$(cat ~/swiftnode/blockcount)
currentBlock=$(swiftcash-cli getblockcount)

swiftcash-cli getblockcount > ~/swiftnode/blockcount

if [ "$previousBlock" == "$currentBlock" ]; then
  swiftcash-cli stop
  sleep 10
  swiftcashd
fi
