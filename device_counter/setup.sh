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
echo ''

#Menue
echo -e '\e[0m|---------------------------------------|  '
echo -e ' Main Menue:                                    '
echo -e ' \e[34m[0]\e[0m Activate Cronjob                '
echo -e ' \e[34m[1]\e[0m Deactivate Cronjob              '
echo -e ' \e[34m[2]\e[0m Start full setup                '
echo -e ' \e[34m[3]\e[0m Start full setup in verbose mode'
echo -e ' \e[34m[4]\e[0m Clear captured Data             '
echo -e '\e[0m|---------------------------------------|  '
read -p 'Enter number:' CONT
if [ "$CONT" = "0" ]; then
  echo -e '\e[34m[*]      \e[32mActivating cronjob                   \e[34m[*]\e[0m'
  LOCAT=$(pwd);
  crontab -l > newcron;
  echo "* * * * * "$LOCAT"/all_in_one.sh" >> newcron;
  crontab newcron;
  rm newcron;
  echo -e '\e[33mDone'
  sleep 1
  exit 130
elif [ "$CONT" = "1" ]; then
  echo -e '\e[34m[*]      \e[32mDeactivating cronjob                   \e[34m[*]\e[0m'
  sed -i '/all_in_one.sh/d' /var/spool/cron/crontabs/root
  echo -e '\e[33mDone'
  sleep 1
  exit 130
elif [ "$CONT" = "2" ]; then
  echo "Starting the full setup";
  VERB1=">/dev/null"
  VERB2="&>/dev/null"
elif [ "$CONT" = "3" ]; then
  VERB1=''
  VERB2=''
  echo "Starting the full setup in verbose mode";
elif [ "$CONT" = "4" ]; then
  read -p 'Are you sure that you want to clear all captured data(y/n)?' VERY
  if [ "$VERY" = "y" ]; then
    echo -e '\e[34m[*]      \e[32mClearing all captured Data                   \e[34m[*]\e[0m'
    sleep 1
    #Remove backups
    if ! [ -d "/btfinder/backups" ];then
      rm /btfinder/backups/*.txt
    fi
    if ! [ -d "/wififinder/backups" ];then
      rm /wififinder/backups/*.csv
    fi
    #Clear countedmacs.txt
    sed -i -e 1c"0" countedmacs.txt
    echo -e '\e[33mDone'
    exit 130
  else
    echo -e '...Nothing happend'
    exit 130
  fi
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


##Installing dependencies
echo -e '\e[34m[*]      \e[32mInstalling dependencies			\e[34m[*]\e[0m'
#> /dev/null and &> /dev/null
eval apt-get install aircrack-ng -y $VERB1
eval pip install -U -v Flask $VERB2
echo -e '\e[33mDone'


##Adjusting permissions
echo -e '\e[34m[*]      \e[32mAdjusting permissions				\e[34m[*]'
eval chmod -v +x all_in_one.sh $VERB1
eval chmod -v +x launch_website.sh $VERB1
eval chmod -v +x wifi_start_scan.sh $VERB1
eval chmod -v +x count_sorted.py $VERB1 
sleep 1
echo -e '\e[33mDone'


##Adjusting path in files
echo -e '\e[34m[*]      \e[32mAdjusting path in files			\e[34m[*]\e[0m'
#Get path to update
LOCAT=$(pwd)
eval echo -e Using $LOCAT as the path to the device_counter folder $VERB1

#Read path of the all_in_one.sh file(line2).
CURRPATH=$(sed '2q;d' all_in_one.sh)
CURRPATH="${CURRPATH:1}"

#Update current path with new path in all_in_one.sh
eval sed -i --debug "s,$CURRPATH,$LOCAT," all_in_one.sh $VERB2
eval sed -i --debug "s,$CURRPATH,$LOCAT," launch_website.sh $VERB2
eval sed -i --debug "s,$CURRPATH,$LOCAT," wifi_start_scan.sh $VERB2
eval sed -i --debug "s,$CURRPATH,$LOCAT," count_sorted.py $VERB2
cd web/
eval sed -i --debug "s,$CURRPATH,$LOCAT," myapp.py $VERB2
sleep 1
echo -e '\e[33mDone'


#Check for backupfolder
echo -e '\e[34m[*]      \e[32mCheck for backupfolder                            \e[34m[*]\e[0m'
if ! [ -d "$LOCAT/btfinder/backups" ];then
   eval mkdir -v $LOCAT/btfinder/backups $VERB1;
fi
if ! [ -d "$LOCAT/wififinder/backups" ];then
   eval mkdir -v $LOCAT/wififinder/backups $VERB1;
fi
sleep 1
echo -e '\e[33mDone'


##Setting up cronjob
#Removing old cronjob(The sed command realy removes every line with the matching string in it!)
sed -i '/all_in_one.sh/d' /var/spool/cron/crontabs/root

#Setting up new cronjob
echo -e '\e[34m[*]      \e[32mSetting up Cronjob                   		\e[34m[*]\e[0m'
crontab -l > newcron
echo "* * * * * "$LOCAT"/all_in_one.sh" >> newcron
eval crontab newcron $VERB2
rm newcron
sleep 1
echo -e '\e[33mDone'
