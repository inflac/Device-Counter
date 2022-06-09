# Device-Counter
This script gives you the possibility to scan your surrounding for devices that have Wi-Fi and/or Bluetooth turned on. The main purpose is to count how many people crossed a specific spot. The Script uses the Wi-Fi and Bluetooth MAC-address of devices to count how many people traveled by.

An example for the usage is that you have a shop and would like to know how many people enter it per day. You just install a Raspberry Pi near the entrance. With a cronjob, you control when the scanner is active. With the cleanup tool, you can erase the data after every day, so the next day you can count again from zero.
Now you sit in your office and open the web browser on your computer. You type in the IP:5000 of the Raspberry Pi and watch the number increasing :).

## Problems
* How do I count people who do not have any devices with them? Sure, the script can only count devices of people that have Wi-Fi and/or Bluetooth activated, but if you take a look at your phone now, most people will see that at least one of the two things is turned on. That leads us to the second problem. 
* What if people have Wi-Fi and Bluetooth activated? The answer is easy. They get counted twice! And yes, that leads to a false number of counted devices. The problem can be put into perspective in that not all people have Wi-Fi and/or Bluetooth activated and would not be counted at all. In addition, there is no guarantee that all devices will actually be detected. This could be due to slow hardware. For example, an older Raspberry Pi on which the script is running. It can therefore be assumed that people who are counted twice compensate not counted ones.
* Don't the MAC-address of mobile devices change after some time? Because of many mobile devices have anti tracking mechanisms, they do not broadcast their real and unique MAC-address. Most often, mobile devices broadcast fake addresses that change after some time. But still the change rhythm is long enough to count a device only once if the scanner runs for example just a couple of hours.

## Setup
A description will appear in the next few days ^^
