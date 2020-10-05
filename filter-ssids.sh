#!/bin/bash

#
# Usage: filter-ssids <airodump log file> <output file prefix> "<ssid1 ssid2 ...>"
#
#
# Description:
#
# This script takes the <filename>.csv file produced by running:
#
#    airodump-ng --beacons --manufacturer --uptime --wps --write <filename> mon1
#
# filters for selected SSIDs passed as a string on the commandline into a
# new file mirroring the originial.
#
# This script assumes only WPA and WPA2 encryption to reporduce sections
# of the log file.
#
# Configuration:
#
#    1. Run `iw dev` to determine available wireless network devices
#    2. Identify the interface to use for monitoring, i.e. wlan0 or wlan1
#    3. Verify the device can spport monitoring mode `iw phy <phy1> info`
#    4. Edit /etc/netowrk/interfaces; replace <phy1> with interface.
#        <snip>
#        allow-hotplug <phy1>
#        iface <phy1> inet manual
#        pre-up iw phy <phy1> interface add mon1 type monitor
#        pre-up iw dev wlan1 del
#        pre-up ifconfig mon1 up
#        </snip>
#    5. Reboot
#    6. Verify mon1 with ifconfig
#
# Reference:
#
# https://pimylifeup.com/raspberry-pi-network-scanner/
#

if [ $# -ne 3 ]
then
echo 'Usage: ' $0 ' <logfile> <domain> "<ssid1> <ssid2> ..."'
exit
fi

infile=$1
domain=$2
ssids=$3

datestamp=`date --rfc-3339=date`
base=${domain}-${datestamp}

#
# Filter for domain
#
head -2 $infile  > ${base}.csv

for i in $ssids
do
grep $i $infile | grep -i wpa >> ${base}.csv
done

echo >> ${base}.csv
grep Station $infile  >> ${base}.csv

for i in $ssids
do
grep $i $infile | grep -v -i wpa >> ${base}.csv
done

#
# Make Graphs
#
for i in CPG CAPR
do
airgraph-ng -i ${base}.csv -o ${base}-${i}.png -g ${i} > /dev/null 2>&1
done
