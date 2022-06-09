#!/usr/bin/python3
import os

filePath = "/home/kali/Desktop/device_counter/wififinder/sorted_macs.txt"
with open(filePath, 'r') as f:
    macs = set([_.rstrip('\n') for _ in f.readlines()])
f.close()

os.remove("/home/kali/Desktop/device_counter/wififinder/sorted_macs.txt")
with open(filePath, 'w+') as w:
    for i in macs:
         w.write(i + "\n")
all_counted_wifi = len(macs)
w.close()

filePath = "/home/kali/Desktop/device_counter/btfinder/sorted_macs.txt"
with open(filePath, 'r') as g:
    macs = set([_.rstrip('\n') for _ in g.readlines()])
g.close()


os.remove("/home/kali/Desktop/device_counter/btfinder/sorted_macs.txt")
with open(filePath, 'w+') as b:
    for i in macs:
         b.write(i + "\n")
all_counted_bluetooth = len(macs)
b.close()


os.remove("/home/kali/Desktop/device_counter/countedmacs.txt")
datei_neu = open('/home/kali/Desktop/device_counter/countedmacs.txt','w+')
datei_neu.write(str(int(all_counted_wifi)+int(all_counted_bluetooth)))
print(str(int(all_counted_wifi)+int(all_counted_bluetooth)))
