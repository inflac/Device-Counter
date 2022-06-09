airmon-ng start wlan1
airodump-ng --berlin 60000 -w /home/kali/Desktop/device_counter/wififinder/WIFICapture --channel 1-13,36-165 --write-interval 10 --output-format csv wlan1mon
