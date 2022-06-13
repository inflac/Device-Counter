#!/bin/bash

##intro
echo -e '     _            _                                  _            '
echo -e '    | |          (_)                                | |           '
echo -e '  __| | _____   ___  ___ ___    ___ ___  _   _ _ __ | |_ ___ _ __ '
echo -e ' / _` |/ _ \ \ / / |/ __/ _ \  / __/ _ \| | | | '"' _\| __/ _ \ '"'__|   '
echo -e '| (_| |  __/\ V /| | (_|  __/ | (_| (_) | |_| | | | | ||  __/ |   '
echo -e ' \__,_|\___| \_/ |_|\___\___|  \___\___/ \__,_|_| |_|\__\___|_|   '
echo -e ''

echo ''
echo ''
echo -e '\e[34m[*]	\e[32mDevice Counter							\e[34m[*]'
echo -e '\e[34m[*]	\e[32mVersion : 1.0 							\e[34m[*]'
echo -e '\e[34m[*]	\e[32mReport Bugs : https://github.com/inflac/Device-Counter/issues	\e[34m[*]'
echo -e '\e[34m[*]	\e[32mCreated By : \e[33mInflac						\e[34m[*]'
echo -e '\e[34m[*]	\e[32mBased on '"'\e[36mAircrack-ng'"' \e[32m& '"'\e[36mBlue Control'"'				\e[34m[*]'
echo ''
echo -e '\e[0mThe Script will do the following things:'
echo '--> Install aircrack-ng'
echo '--> Install flask'
echo '--> Change permissions of the files in the folder "device_counter"'
echo '--> Edit content of the files in the folder "device_counter"'
echo ''

read -p "Would you like to start the setup now (y/n)?" CONT
if [ "$CONT" = "y" ]; then
  echo "...Starting";
elif [ "$CONT" = "n" ]; then
  echo "See you later";
  exit 130
else
  echo ''
  echo -e '\e[31m########################################\e[0m'
  echo -e "You did not accepted or declined the start of the setup!"
  echo -e "You will now get an other occupation"
  echo -e "Your very personal film experience will start in just a few seconds. Today we show Star Wars!"
  echo -e '\e[31m########################################\e[0m'
  sleep 10
  telnet towel.blinkenlights.nl
fi

##install dependencies
echo -e '\e[34m[*]      \e[32mInstalling Dependencies			\e[34m[*]'
apt-get install aircrack-ng -y > /dev/null
pip install -U Flask &> /dev/null
echo -e '\e[33mDone'

##adjust permissions for scripts
echo -e '\e[34m[*]      \e[32mAdjusting Permissions				\e[34m[*]'
chmod +x all_in_one.sh
chmod +x launch_website.sh
chmod +x wifi_start_scan.sh
sleep 1
echo -e '\e[33mDone'

##Read in path
echo -e '\e[34m[*]      \e[32mEnter Location of device_counter folder	\e[34m[*]'
LOCAT=$(pwd)
echo -e Using $LOCAT as the path to the device_counter folder
sleep 1
echo -e '\e[33mDone'

##Change path in files
echo -e '\e[34m[*]      \e[32mAdjust path in files   \e[34m[*]'
#LOCAT is the path to use. Maybe <sed -i 's/search_string/replace_string/' filename> can help.
#It could look like <sed -i 's/current path/$LOCAT/' all files>
#TODO

sleep 1
echo -e '\e[33mDone'
