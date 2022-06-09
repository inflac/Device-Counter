#!/bin/bash
bluetoothctl --timeout 30 scan on > /home/kali/Desktop/device_counter/btfinder/BTCapture.txt

#Bluetooth
cd /home/kali/Desktop/device_counter/btfinder
grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' BTCapture.txt >> /home/kali/Desktop/device_counter/btfinder/sorted_macs.txt

#Wifi
cd /home/kali/Desktop/device_counter/wififinder
grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' WIFICapture-01.csv >> /home/kali/Desktop/device_counter/wififinder/sorted_macs.txt

#Count
cd /home/kali/Desktop/device_counter
./count_sorted.py

#Afterrun
##Wifi
cd /home/kali/Desktop/device_counter/wififinder
actualtimewifi=$(date +%T)
cp WIFICapture-01.csv /home/kali/Desktop/device_counter/wififinder/backups/WIFICapture-$actualtimewifi.csv
##Bluetooth
cd /home/kali/Desktop/device_counter/btfinder
rm BTCapture.txt
actualtimebluetooth=$(date +%T)
cp sorted_macs.txt /home/kali/Desktop/device_counter/btfinder/backups/sorted_macs_backup_$actualtimebluetooth.txt
