# SwiftNode-Installer
### Bash installer for swiftnode on Linux

#### This shell script comes with 3 cronjobs: 
1. Make sure the daemon is always running: `makerun.sh`
2. Make sure the daemon is never stuck: `checkdaemon.sh`
3. Clear the log file every other day: `clearlog.sh`

#### Take note of the following points
1. You need exactly 50K SWIFT sent to a unique SwiftCash address
2. Wallet stakes coins that are more than 1 hour old by default so be careful to lock your SWIFT txid asap. Adding the txid to swiftnode.conf and restarting the wallet will do this automatically.
3. Each txid requires at least 20 confirmations before they become eligible for securing a swiftnode

#### On the client-side, add the following line to swiftnode.conf

`SN01 VPS-IP-ADDRESS:8544 SWIFTNODE-GEN-KEY COLLATERAL-TX-ID COLLATERAL-TX-OUTPUT`

#### Login to your vps as root, download the install.sh file and then run it, enter the SwiftNodeKey you got above when asked for SwiftNode GenKey:
```
wget https://raw.githack.com/swiftcashproject/swiftnode-installer/master/install.sh -O install.sh
bash ./install.sh
```

#### Run the qt wallet, go to SwiftNodes tab, choose your node and click "Start alias" at the bottom.

#### You're good to go now. BE $SWIFT! https://swiftcash.cc
