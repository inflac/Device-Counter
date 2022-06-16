WLAN=$(ip link show | awk '{print $2}' | grep "wlan" | sort -k 1,1 | tail -1)
if [ "$WLAN" = "" ]; then
  echo ''
  echo ''
  echo '\e[31mWARNING: Scanning with Wi-Fi is not possible!';
  echo 'Note: If you are only scanning with Bluetooth, you do not need \nto start the wifi_start_scan.sh script!';
  echo 'Reason: It wasnt possible to detect any Wi-Fi adapter. Please try to detache or deactivate the adapter and then reattach  or reactivate it.';
  echo ''
  echo ''
  exit 130
else
  WLAN=${WLAN%?}
fi
airmon-ng start $WLAN
airodump-ng --berlin 60000 -w /home/kali/Desktop/device_counter/wififinder/WIFICapture --channel 1-13,36-165 --write-interval 10 --output-format csv $WLAN
