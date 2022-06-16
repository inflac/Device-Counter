# Device-Counter
This script gives you the possibility to scan your surrounding for devices that have Wi-Fi and/or Bluetooth turned on. The main purpose is to count how many people crossed a specific spot. The Script uses the Wi-Fi and Bluetooth MAC-address of devices to count how many people traveled by.

An example for the usage could be that you have a shop and would like to know how many people enter it per day. You just install a Raspberry Pi near the entrance. With a cronjob, you control when the scanner is active. With the cleanup tool, you can erase the data after every day, so the next day you can count again from zero.
Now you sit in your office and open the web browser on your computer. You type in the IP:5000 of the Raspberry Pi and watch the number increasing :).

## Problems
* How do I count people who do not have any devices with them? Sure, the script can only count devices of people that have Wi-Fi and/or Bluetooth activated, but if you have a look at your phone right now, most people will see that at least one of the two things is turned on. That leads us to the second problem. 
* What if people have Wi-Fi and Bluetooth activated? The answer is easy. They get counted twice! And yes, that leads to a false number of counted devices. The problem can be put into perspective in that not all people have Wi-Fi and/or Bluetooth activated and would not be counted at all. In addition, there is no guarantee that all devices will actually be detected. This could be due to slow hardware. For example, an older Raspberry Pi on which the script is running. It can therefore be assumed that people who are counted twice compensate not counted ones.
* Don't the MAC-address of mobile devices change after some time? Because of many mobile devices have anti tracking mechanisms, they do not broadcast their real and unique MAC-address. Most often, mobile devices broadcast fake addresses that change after some time. But still the change rhythm is long enough to count a device only once if the scanner runs for example just a couple of hours. I've read that most devices of big brands only change their MAC addresses when they connect to new networks. Since you don't change your Wi-Fi/Bluetooth network very often in public spaces, changing MAC addresses shouldn't be a problem.

## Setup
To ensure everything is working fine, you should run the following commands as root.
### Steps needed to do once or after every path change:
1) Place the folder "device_counter" into the file system. I like using "Desktop" of the user I'm logged into, but you can choose anyone.
2) Go into the folder "device_counter" with `cd` for example `cd /home/user/Desktop/device_counter`.
3) Now change the permissions of the setup.sh file with `chmod +x setup.sh`.
4) Start the Script setup.sh with `./setup.sh`
5) After the script finished, you are ready to go.

### Steps needed to do every time:
1) To run the WI-FI Scanner, you will first have to plug in an external Wi-Fi adapter, for example via USB.
2) Open a command prompt.
3) Move into the "device_counter" folder with `cd` for example `cd /home/user/Desktop/device_counter`.
4) If there is no cronjob running you can now start the "setup.sh" script with `setup.sh`.
5) Choose "1" to activate the cronjob.
6) Then run the script wifi_start_scan.sh. You can do it with `./wifi_start_scan.sh`.
7) The command prompt needs to run the whole time you're scanning.
8) Open a new command prompt.
9) Start the graphic representation with `./launch_website.sh`
10) To see the Website, go to 127.0.0.1:5000 on your machine or in your network, go to the IP:5000 of the device the counter is running on.
11) Congratulations, you're done and now counting the devices in your area.

### How to stop scanning?
1) Close the two command prompts you opened at the start of scanning.
2) Now only the cronjob is still running. If you aren't using the machine the device counter is running on only for the counter, you can now also stop the cronjob. Do the following to stop it:
3) Open a command prompt.
4) Move into the "device_counter" folder with `cd` for example `cd /home/user/Desktop/device_counter`.
5) Run the "setup.sh" script with `./setup.sh`.
6) Choose "2" to deactivate the cronjob.

# External ressources
* Ascii font generator: https://patorjk.com/software/taag/
* Wifi: https://github.com/aircrack-ng
* Bluetooth: https://github.com/bluez
