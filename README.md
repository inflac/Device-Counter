# Device-Counter
This script gives you the possibility to scan your surrounding for devices that have Wi-Fi and/or Bluetooth turned on. The main purpose is to count how many people crossed a specific spot. The Script uses the Wi-Fi and Bluetooth MAC-address of devices to count how many people traveled by.

An example for the usage is that you have a shop and would like to know how many people enter it per day. You just install a Raspberry Pi near the entrance. With a cronjob, you control when the scanner is active. With the cleanup tool, you can erase the data after every day, so the next day you can count again from zero.
Now you sit in your office and open the web browser on your computer. You type in the IP:5000 of the Raspberry Pi and watch the number increasing :).

## Problems
* How do I count people who do not have any devices with them? Sure, the script can only count devices of people that have Wi-Fi and/or Bluetooth activated, but if you take a look at your phone now, most people will see that at least one of the two things is turned on. That leads us to the second problem. 
* What if people have Wi-Fi and Bluetooth activated? The answer is easy. They get counted twice! And yes, that leads to a false number of counted devices. The problem can be put into perspective in that not all people have Wi-Fi and/or Bluetooth activated and would not be counted at all. In addition, there is no guarantee that all devices will actually be detected. This could be due to slow hardware. For example, an older Raspberry Pi on which the script is running. It can therefore be assumed that people who are counted twice compensate not counted ones.
* Don't the MAC-address of mobile devices change after some time? Because of many mobile devices have anti tracking mechanisms, they do not broadcast their real and unique MAC-address. Most often, mobile devices broadcast fake addresses that change after some time. But still the change rhythm is long enough to count a device only once if the scanner runs for example just a couple of hours.

## Setup
To ensure everything is working fine, you can run the following commands as root or with sudo permissions.
### Steps needed to do once:
1) Place the folder "device_counter" into the file system. I like using "Desktop" of the user I'm logged in, but you can choose anyone.
2) Go into the folder "device_counter" and run `chmod +x setup.sh`.
3) Start the Script setup.sh with `./setup.sh`
4) After the script finished, you are ready to go.

### Steps needed to do every time:
1) To run the WI-FI Scanner, you will first have to plug in an external Wi-Fi adapter, for example via USB.
2) Open a command prompt.
3) Then run the script wifi_start_scan.sh. You can do it with `./wifi_start_scan.sh`.
4) The command prompt needs to run the whole time you're scanning.
5) Open a new command prompt.
6) Start the graphic representation with `./launch_website.sh`
7) To see the Website, go to 127.0.0.1:5000 on your machine or in your network, go to the IP:5000 of the device the counter is running on.
8) Congratulations, you're done and now counting the devices in your area.

### How to stop scanning?
1) Close the two command prompts you opened at the start of scanning.
2) Now only the cronjob is still running. If you aren't using the machine the device counter is running on only for the counter, you can now also stop the cronjob. Do the following to stop it:
3) Open a command prompt.
4) Type in `crontab -e`.
5) Go to the end of the file and look for something like this: "Here will be the crontab code from the setup.sh script".
6) Go to the beginning of the line and type `#`. The line now should change the color and look like `#ToEnter`.
7) Save the file and exit.
8) Every time you would like to run the script again, remove the `#` in front of the line again and save the file. A `#` is used to comment out content. If the line in the crontab file is commented out, it will be ignored by crontab.

#TODO
setup.sh: Let the user choose between activate / deactivate cronjob and start full setup
