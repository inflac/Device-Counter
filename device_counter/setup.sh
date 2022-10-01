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
echo -e 'The Script will do the following things:'
echo '--> Install aircrack-ng'
echo '--> Install flask'
echo '--> Change permissions of the files in the folder "device_counter"'
echo '--> Edit content of the files in the folder "device_counter"'
echo '--> Setup Cronjob for all_in_one.sh'
echo ''

#Menue
echo -e '\e[0m|---------------------------------------|  '
echo -e ' Main Menue:                                    '
echo -e ' \e[34m[0]\e[0m Start full setup                '
echo -e ' \e[34m[1]\e[0m Start full setup in verbose mode'
echo -e ' \e[34m[2]\e[0m Stop scanning                   '
echo -e ' \e[34m[3]\e[0m Clear captured Data             '
echo -e '\e[0m|---------------------------------------|  '
LOCAT=$(pwd)
read -p 'Enter number:' CONT
if [[ $CONT == '0' ]]; then
  echo 'Starting the full setup';
  VERB1='>/dev/null'
  VERB2='&>/dev/null'
elif [[ $CONT == '1' ]]; then
  VERB1=''
  VERB2=''
  echo 'Starting the full setup in verbose mode';
elif [[ $CONT == '2' ]]; then
  echo -e '\e[34m[*]      \e[32mStop scanning                   \e[34m[*]\e[0m'
  #stoping the cronjob
  sed -i '/all_in_one.sh/d' /var/spool/cron/crontabs/root
  #stop wi-fi scanning
  eval pkill -e -f airodump-ng $VERB1
  #stop flask
  eval pkill -e -f flask $VERB1
  #backup and move data
  actualtime=$(date +%T)
  mv $LOCAT/wififinder/WIFICapture-01.csv $LOCAT/wififinder/backups/WIFICapture-$actualtime.csv
  echo -e '\e[33mDone'
  sleep 1
  exit 130
elif [[ $CONT == '3' ]]; then
  read -p 'Are you sure that you want to clear all captured data(y/n)?' VERY
  if [[ $VERY == 'y' ]]; then
    echo -e '\e[34m[*]      \e[32mClearing all captured Data                   \e[34m[*]\e[0m'
    #Remove backups
    if [[ -d $LOCAT'/btfinder/backups' ]]; then
      rm -r -f $LOCAT/btfinder/backups/*.txt
      rm $LOCAT/btfinder/sorted_macs.txt && touch $LOCAT/btfinder/sorted_macs.txt
    fi
    if [[ -d $LOCAT'/wififinder/backups' ]]; then
      rm -r -f $LOCAT/wififinder/backups/*.csv
      rm $LOCAT/wififinder/sorted_macs.txt && touch $LOCAT/wififinder/sorted_macs.txt
    fi
    #Clear countedmacs.txt
    sed -i -e 1c'0' $LOCAT/countedmacs.txt
    sleep 1
    echo -e '\e[33mDone'
    exit 130
  else
    echo -e '...Nothing happend'
    exit 130
  fi
else
  echo ''
  echo -e '\e[31m########################################\e[0m'
  echo -e 'You did not accepted or declined the start of the setup!'
  echo -e 'You will now get an other occupation'
  echo -e 'Your very personal film experience will start in just a few seconds. Today we show Star Wars!'
  echo -e '\e[31m########################################\e[0m'
  sleep 10
  telnet towel.blinkenlights.nl
fi


#Stop running scans
echo -e '\e[34m[*]      \e[32mKill running scans                             \e[34m[*]\e[0m'
eval pkill -e -f airodump-ng $VERB1
eval pkill -e -f flask $VERB1
sleep 1
echo -e '\e[33mDone\e[0m'


#Adjusting permissions
echo -e '\e[34m[*]      \e[32mAdjusting permissions                          \e[34m[*]'
eval chmod -v +x all_in_one.sh $VERB1
eval chmod -v +x count_sorted.py $VERB1
sleep 1
echo -e '\e[33mDone'


##Adjusting path in files
echo -e '\e[34m[*]      \e[32mAdjusting path in files                        \e[34m[*]\e[0m'
#Get path to update
eval echo -e Using $LOCAT as the path to the device_counter folder $VERB1

#Read path of the all_in_one.sh file(line2).
CURRPATH=$(sed '2q;d' all_in_one.sh)
CURRPATH=${CURRPATH:1}

#Update current path with new path in all_in_one.sh
eval sed -i --debug 's,$CURRPATH,$LOCAT,' all_in_one.sh $VERB2
eval sed -i --debug 's,$CURRPATH,$LOCAT,' count_sorted.py $VERB2
eval sed -i --debug 's,$CURRPATH,$LOCAT,' web/myapp.py $VERB2
sleep 1
echo -e '\e[33mDone'


#Check for backupfolder
echo -e '\e[34m[*]      \e[32mCheck for backupfolder                         \e[34m[*]\e[0m'
if ! [[ -d $LOCAT'/btfinder/backups' ]];then
   eval mkdir -v $LOCAT/btfinder/backups $VERB1;
fi
if ! [[ -d $LOCAT'/wififinder/backups' ]];then
   eval mkdir -v $LOCAT/wififinder/backups $VERB1;
fi
sleep 1
echo -e '\e[33mDone'


#Move scan results to backups
echo -e '\e[34m[*]      \e[32mMove scan results                              \e[34m[*]\e[0m'
actualtime=$(date +%T)
mv $LOCAT/wififinder/WIFICapture-01.csv $LOCAT/wififinder/backups/WIFICapture-$actualtime.csv
sleep 1
echo -e '\e[33mDone\e[0m'


#Installing dependencies
echo -e '\e[34m[*]      \e[32mInstalling dependencies			\e[34m[*]\e[0m'
if [[ -x "$(command -v apk)" ]];       then eval apk add --no-cache aircrack-ng -y $VERB1
 elif [[ -x "$(command -v apt-get)" ]]; then eval apt-get install aircrack-ng -y $VERB1
 elif [[ -x "$(command -v dnf)" ]];     then eval dnf install aircrack-ng -y $VERB1
 elif [[ -x "$(command -v zypper)" ]];  then eval zypper install aircrack-ng -y $VERB1
 else echo 'FAILD TO INSTALL PACKAGE: Package manager not found. You must manually install: aircrack-ng'
fi
eval pip install -U -v Flask $VERB2
echo -e '\e[33mDone\e[0m'


#Test if scanning with wi-fi is possible
startwifiscan='false'
echo -e '\e[34m[*]      \e[32mTesting wi-fi					\e[34m[*]\e[0m'
WLAN=$(ip link show | awk '{print $2}' | grep 'wlan' | sort -k 1,1 | tail -1)
if [[ $WLAN == '' ]]; then
  echo -e '\e[31mWARNING: Scanning with Wi-Fi is not possible!';
  echo -e 'Note: If you are only scanning with Bluetooth, you can ignore this message.';
  eval echo -e 'Reason: It wasnt possible to detect any Wi-Fi adapter. Please try to detache or deactivate the adapter and then reattach  or reactivate it.' $VERB1;
  eval echo -e 'Hint: If you are sure that Wi-Fi scanning should be possible, you can try running the wifi_start_scan.sh skript.' $VERB1;
  eval echo -e 'Do not close the terminal in which you started the skript, as it needs to run the whole time you want to scan for devices.' $VERB1;
  sleep 1
else
  eval echo -e 'using interface: $WLAN' $VERB1;
  startwifiscan="true"
fi
echo -e '\e[33mDone\e[0m'


#Start scanning with wi-fi
echo -e '\e[34m[*]      \e[32mStart scanning with wi-fi                      \e[34m[*]\e[0m'
if [[ $startwifiscan == 'true' ]]; then
  WLAN=$(airmon-ng | awk '{print $2}' | grep 'wlan' | sort -k 1,1 | tail -1)
  eval airmon-ng --verbose start $WLAN $VERB2
  sleep 1
  nohup airodump-ng --berlin 60000 -w /home/kali/device_counter/wififinder/WIFICapture --channel 1-13,36-165 --write-interval 10 --output-format csv $WLAN &>/dev/null &
else
  echo -e '\e[31mBecause Scanning with Wi-Fi is not possible as detected above'
  echo -e 'no scann was initialized!\e[0m'
  sleep 1
fi
echo -e '\e[33mDone\e[0m'


#Test if scanning with bluetooth is possible
echo -e '\e[34m[*]      \e[32mTesting bluetooth				\e[34m[*]\e[0m'
BLUE=$(dmesg | grep -i Bluetooth)
COMM=$(sed -n 3p all_in_one.sh)
if [[ $BLUE = '' ]]; then
  if [[ ${COMM::1} != '#' ]]; then
    sed -i '3s/^/#/' all_in_one.sh;
  fi
  echo -e '\e[31mWARNING: Scanning with Bluetooth is not possible!';
  echo -e 'Note: If you are only scanning with Wi-Fi, you can ignore this message.';
  eval echo -e 'Reason: It wasnt possible to detect any Bluetooth adapter. Please try to detache or deactivate the adapter and then reattach  or reactivate it.' $VERB1;
  eval echo -e 'Function: The line for scanning with bluetooth in all_in_one.sh was deactivated by adding a \"#\" at the beginning of the line.' $VERB1;
  eval echo -e 'If you want to debug the issue by yourself, you can try to manually reactivate the line by removing the \"#\"' $VERB1;
  startblescan='false'
else
  if [[ ${COMM::1} == '#' ]]; then
    sed -i '3s/^.//' all_in_one.sh;
  fi
  startblescan='true'
fi
sleep 1
echo -e '\e[33mDone\e[0m'


##Setting up cronjob
  echo -e '\e[34m[*]      \e[32mSetting up Cronjob                              \e[34m[*]\e[0m'
if [[ $startwifiscan == 'false' && $startblescan == 'false' ]]; then
  echo -e 'No Cronjob initilized'
  eval echo -e 'Reason: Scanning with wifi and bluetooth is not possible, so there is no use for the all_in_one.sh skript.' $VERB1;
else
  #Removing old cronjob(The sed command realy removes every line with the matching string in it!)
  sed -i '/all_in_one.sh/d' /var/spool/cron/crontabs/root

  #Setting up new cronjob
  crontab -l > allinone
  echo '* * * * * '$LOCAT'/all_in_one.sh' >> allinone
  eval crontab allinone $VERB2
  rm allinone
fi
  sleep 1
echo -e '\e[33mDone\e[0m'

echo -e '\e[34m[*]      \e[32mStart the web application                      \e[34m[*]\e[0m'
if [[ $startwifiscan == 'false' && $startblescan == 'false' ]]; then
  read -p 'Neither wi-fi nor bluetooth scanning is possible. Do you want to start the website anyway(y/n)?' STARTWEB
  if [[ $STARTWEB == 'n' || $STARTWEB == 'N' ]]; then
    echo -e 'Website not launched'
  elif [[ $STARTWEB == 'y' || $STARTWEB == 'Y' ]]; then
    cd $LOCAT/web
    export FLASK_APP=myapp
    export FLASK_ENV=development
    nohup flask run &>/dev/null &
    cd $LOCAT
    eval echo -e 'Website launched' $VERB1;
  else
    echo -e 'False answer, website was not launched!'
  fi
else
  eval echo -e 'Website launched' $VERB1;
  cd $LOCAT/web
  export FLASK_APP=myapp
  export FLASK_ENV=development
  nohup flask run &>/dev/null &
  cd $LOCAT
fi
echo -e '\e[33mDone\e[0m'


#Evaluation
if [[ $startwifiscan == 'false' && $startblescan == 'false' ]]; then
  STATUS='\e[33mNO SCAN ACTIVE\e[0m'
  SPACER='\e[32m##############\e[0m'
elif [[ $startwifiscan == 'true' && $startblescan == 'false' ]]; then
  STATUS='\e[33mONLY WIFI SCAN\e[0m'
  SPACER='\e[32m##############\e[0m'
elif [[ $startwifiscan == 'false' && $startblescan == 'true' ]]; then
  STATUS='\e[33mONLY BLUETOOTH SCAN\e[0m'
  SPACER='\e[32m###################\e[0m'
elif [[ $startwifiscan == 'true' && $startblescan == 'true' ]]; then
  STATUS='\e[33mBOTH SCANS ACTIVE\e[0m'
  SPACER='\e[32m##################\e[0m'
else
  STATUS='ERROR'
fi

#Evaluation message
echo -e ''
echo -e ''
echo -e '\e[32m##################|\e[0m'$STATUS'\e[32m|###################\e[0m'
if [[ $STARTWEB == 'n' || $STARTWEB == 'N' ]]; then
  echo -e '\e[34mWebsite URL:\e[0m NOT LAUNCHED'
else
  echo -e '\e[34mWebsite URL:\e[0m http://127.0.0.1:5000'
fi
echo -e ''
echo -e ''
echo -e '\e[32m##################\e[0m'$SPACER'\e[32m#####################\e[0m'
