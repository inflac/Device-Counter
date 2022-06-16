WLAN=$(ip link show | awk '{print $2}' | grep "wlan" | sort -k 1,1 | tail -1)
WLAN=${WLAN%?}
airmon-ng start $WLAN
airodump-ng --berlin 60000 -w /home/kali/Desktop/device_counter/wififinder/WIFICapture --channel 1-13,36-165 --write-interval 10 --output-format csv $WLAN
