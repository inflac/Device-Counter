# Device-Counter
This script gives you the possibility to scan your surrounding for devices that have Wi-Fi and/or Bluetooth turned on. The main purpose is to count how many people crossed a specific spot. The Script uses the Wi-Fi and Bluetooth MAC-address of devices to count how many people traveled by.

An example for the usage could be that you have a shop and would like to know how many people enter it per day. You just install a Raspberry Pi near the entrance. With a cronjob, you control when the scanner is active. With the cleanup tool, you can erase the data after every day, so the next day you can count again from zero.
Now you sit in your office and open the web browser on your computer. You type in the IP:5000 of the Raspberry Pi and watch the number increasing :).

![image](https://user-images.githubusercontent.com/74843899/174181705-dc685ad0-d937-4f64-bbe0-cefa2b7292ad.png)

## Problems
* How do I count people who do not have any devices with them? Sure, the script can only count devices of people that have Wi-Fi and/or Bluetooth activated, but if you have a look at your phone right now, most people will see that at least one of the two things is turned on. That leads us to the second problem. 
* What if people have Wi-Fi and Bluetooth activated? The answer is easy. They get counted twice! And yes, that leads to a false number of counted devices. The problem can be put into perspective in that not all people have Wi-Fi and/or Bluetooth activated and would not be counted at all. In addition, there is no guarantee that all devices will actually be detected. This could be due to slow hardware. For example, an older Raspberry Pi on which the script is running. It can therefore be assumed that people who are counted twice compensate not counted ones.
* Don't the MAC-address of mobile devices change after some time? Because of many mobile devices have anti tracking mechanisms, they do not broadcast their real and unique MAC-address. Most often, mobile devices broadcast fake addresses that change after some time. But still the change rhythm is long enough to count a device only once if the scanner runs for example just a couple of hours. I've read that most devices of big brands only change their MAC addresses when they connect to new networks. Since you don't change your Wi-Fi/Bluetooth network very often in public spaces, changing MAC addresses shouldn't be a problem.

## Setup
![image](https://user-images.githubusercontent.com/74843899/194777368-422fa027-83a3-49ac-9acc-74d4340f1001.png)

To ensure everything is working fine, you should run the following commands as root.

### Requirements
* Python3 - For the "advanced packaging tool", short apt, you can type `apt install python3`

### Steps needed to do once:
1) Place the folder "device_counter" into the file system. I like using "Desktop" of the user I'm logged into, but you can choose anyone.
2) Go into the folder "device_counter" with `cd` for example `cd /home/user/Desktop/device_counter`.
3) Now change the permissions of the setup.sh file with `chmod +x setup.sh`.

### Steps needed to start a scan:
1) To successfully run a WI-FI Scan, you will first have to plug in an external Wi-Fi adapter, for example via USB.
2) To successfully run a Bluetooth Scan, your device needs Bluetooth, via internal or external adapter.
3) Open a command prompt.
4) Move into the "device_counter" folder with `cd` for example `cd /home/user/Desktop/device_counter`.
5) Now start the "setup.sh" script with `./setup.sh`.
6) Choose "0" to start a scan.
7) To see the Website, go to 127.0.0.1:5000 on your machine or in your network, go to the IP:5000 of the device the counter is running on.
11) Congratulations, you're done and now counting the devices in your area.

### How to stop scanning?
1) Open a command prompt.
2) Move into the "device_counter" folder with `cd` for example `cd /home/user/Desktop/device_counter`.
3) Run the "setup.sh" script with `./setup.sh`.
4) Choose "2" to stop the scan.

### How to analyse data?
1) Choose a sorted_macs.txt file from "wififinder/" or "btfinder/" and copy it to the "device_counter/" folder.
2) Copy latest wifi data: `cp wififinder/sorted_macs.txt ../`
3) Start "setup.sh" with `./setup.sh` and use option "3" in the main menu.

## External ressources
* Ascii font generator: https://patorjk.com/software/taag/
* MAC database: https://maclookup.app/
* Wifi: https://github.com/aircrack-ng
* Bluetooth: https://github.com/bluez


## Todo:
* Update data analyse option.
* Cleanup Code
* super secret operation things xD 
