#!/bin/bash

##Global needed things
#get current path
LOCAT=$(pwd)

#Progressbar constructor
prog_setup() {
  # Progress bar variables
  prog_percent=$1
  prog_symbol="$2"

  prog_width=96
  prog_delimiter=$prog_percent
  while [ $(($prog_width + 20)) -gt $(tput cols) ]; do
    prog_width=$(($prog_width / 2))
    prog_delimiter=$(($prog_delimiter * 2))
  done

  prog_count=$prog_width
  while [ $1 -lt $prog_count ]; do
    prog_delimiter=$(($prog_delimiter * 2))
    prog_symbol="$prog_symbol$prog_symbol"
    prog_count=$(($prog_count / 2))
  done

  prog_bar=""
  prog_completion_old=0

  printf "\033[1;032mProgress:\033[0m\033[s [\033[${prog_width}C] 0%%"
  prog_width=$(($prog_width + 1))
}

prog_update() {
  prog_count=$(($1 * 100))
  prog_completion=$(($prog_count / $prog_percent))

  if [ $prog_completion -ne $prog_completion_old ]; then
    if [ $prog_completion -lt 101 ]; then
      prog_bar=$(printf "%0.s${prog_symbol}" $(seq -s " " 1 $(($prog_count / $prog_delimiter))))
    else
      prog_completion=100
      prog_bar=$(printf "%0.s${prog_symbol}" $(seq -s " " 1 $(($((prog_percent * 100)) / prog_delimiter))))
    fi
    prog_completion_old=$prog_completion
  fi

  printf "\033[u [$prog_bar\033[u \033[${prog_width}C] $prog_completion%%"
}


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
echo '--> Install aircrack-ng, flask and python3-pip'
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
echo -e ' \e[34m[3]\e[0m Analyse Data                    '
echo -e ' \e[34m[4]\e[0m Restore Data                    '
echo -e ' \e[34m[5]\e[0m Clear captured Data             '
echo -e '\e[0m|---------------------------------------|  '
read -p 'Enter number:' CONT
if [[ $CONT == '0' ]]; then
  echo 'Starting the full setup'
  VERB1='>/dev/null'
  VERB2='&>/dev/null'
elif [[ $CONT == '1' ]]; then
  VERB1=''
  VERB2=''
  echo 'Starting the full setup in verbose mode'
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
  echo -e '\e[34m[*]      \e[32mAnalyse Data                       \e[34m[*]\e[0m'
  #Analyze the MAC addresses based on the prefix
  read -p 'Output the analyzed data to a file(y/n)?' CHECKANALYSE
  if [[ $CHECKANALYSE == 'Y' || $CHECKANALYSE == 'y' ]]; then
    actualtime=$(date +%T)
    touch $LOCAT/analyse_result_$actualtime.txt
    OUTPUTANALYSE=">>$LOCAT/analyse_result_$actualtime.txt"
    echo $OUTPUTANALYSE
  else
    OUTPUTANALYSE='>/dev/null'
    echo $OUTPUTANALYSE
  fi
  line=1
  error='false'
  COUNTLINES=$(cat $LOCAT/sorted_macs.txt | wc -l)
  prog_setup $COUNTLINES "#"
  while read macs; do
    brand=$(grep ${macs::8} mac-vendors-export.csv)
    if [[ -z $brand ]]; then
      brand='\e[31mno vendor found - this looks like the MAC is nott valid.\e[0m'
    fi

    #check uniq/locally administrated(7th-bit)
    CHAR=${macs:1:1}
    managed='        \e[31mERROR\e[0m        '
    if [[ $CHAR == '0' || $CHAR == '1' || $CHAR == '4' || $CHAR == '5' || $CHAR == '8' || $CHAR == '9' || $CHAR == 'C' || $CHAR == 'c' || $CHAR == 'D' || $CHAR == 'd' ]]; then
      managed='uniq                 '
    elif [[ $CHAR == '2' || $CHAR == '3' || $CHAR == '6' || $CHAR == '7' || $CHAR == 'A' || $CHAR == 'a' || $CHAR == 'B' || $CHAR == 'b' || $CHAR == 'E' || $CHAR == 'e' || $CHAR == 'F' || $CHAR == 'f' ]]; then
      managed='locally administrated'
    else
      error='true'
    fi

    #check unicast/multicast(8th-bit)
    cast='  \e[31mERROR\e[0m  '
    if [[ $CHAR == '0' || $CHAR == '2' || $CHAR == '4' || $CHAR == '6' || $CHAR == '8' || $CHAR == 'A' || $CHAR == 'a' || $CHAR == 'C' || $CHAR == 'c' || $CHAR == 'E' || $CHAR == 'e' ]]; then
      cast='unicast  '
    elif [[ $CHAR == '1' || $CHAR == '3' || $CHAR == '5' || $CHAR == '7' || $CHAR == '9' || $CHAR == 'B' || $CHAR == 'b' || $CHAR == 'D' || $CHAR == 'd' || $CHAR == 'F' || $CHAR == 'f' ]]; then
      cast='multicast'
    else
      error='true'
    fi

    #output
    lenmac=${#macs}
    if [[ -z $CHAR ]]; then
      eval echo -e "\e[31mERROR: whitespace detected - can not continue! Please remove whitespace from document(line: $line)\e[0m" $OUTPUTANALYSE
    elif [[ $lenmac -gt 17 || $lenmac -lt 17 || $error == 'true' ]]; then
      eval echo -e "\e[31m$macs\e[0m |         \e[31mERROR\e[0m         |   \e[31mERROR\e[0m   | $brand\e[0m" $OUTPUTANALYSE
    else
      eval echo -e "$macs \| $managed \| $cast \| ${brand@Q}" $OUTPUTANALYSE
    fi

    line=$((line+1))
    if [[ $CHECKANALYSE == "Y" || $CHECKANALYSE == "y" ]]; then
      prog_update $line
    else
      echo -e "$macs | $managed | $cast | $brand"
    fi
    done <sorted_macs.txt

  exit 130
elif [[ $CONT == '4' ]]; then
  #restore Data
  echo -e '\e[0m|---------------------------------------|  '
  echo -e ' Restore Menue:                                 '
  echo -e ' \e[34m[0]\e[0m Choose backup file              '
  echo -e ' \e[34m[1]\e[0m Unite all backup files          '
  echo -e '\e[0m|---------------------------------------|  '
  read -p 'Enter number:' ROPTION
  if [[ $ROPTION == '0' ]]; then
    read -p 'Data in the sorted_macs.txt files will be overwritten. Want to proceed(y/n)?' CHECK
    if [[ $CHECK == 'y' || $CHECK == 'Y' ]]; then
      echo -e '\e[34m[*]      \e[32mRestoring Data                       \e[34m[*]\e[0m'
      BACKUPSELECTED='false'
      read -p 'Name of backup file [WIFI]:' BACKUPFILEWIFI
      echo $LOCAT'/wififinder/'$BACKUPFILEWIFI
      if [[ -f $LOCAT'/wififinder/backups/'$BACKUPFILEWIFI ]]; then
        if [[ -s $LOCAT'/wififinder/backups/'$BACKUPFILEWIFI ]]; then
          BACKUPWIFISELECTED='true'
          rm -f $LOCAT'/wififinder/sorted_macs.txt' && touch $LOCAT'/wififinder/sorted_macs.txt'
          grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}" $LOCAT'/wififinder/backups/'$BACKUPFILEWIFI >> $LOCAT'/wififinder/sorted_macs.txt'
        else
          echo -e 'The selected file is empty, nothing was done...'
        fi
      else
        echo -e 'The selected file do not exist, nothing was done ...'
      fi
      read -p 'Name of backup file [BLUETOOTH]:' BACKUPFILEBLE
      if [[ -f $LOCAT'/btfinder/backups/'$BACKUPFILEBLE ]]; then
        if [[ -s $LOCAT'/btfinder/backups'$BACKUPFILEBLE ]]; then
          rm -f $LOCAT'/btfinder/sorted_macs.txt' && touch $LOCAT'/btfinder/sorted_macs.txt'
          grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}" $BACKUPFILEBLE >> $LOCAT'/btfinder/sorted_macs.txt'
        else
          if [[ $BACKUPWIFISELECTED == 'true' && -z $BACKUPFILEBLE ]]; then
            echo -e 'No bluetooth backup file selected! Now processing the selected wifi file'
          else
            echo -e 'The selected file is empty, nothing was done...'
          fi
        fi
      else
        if [[ $BACKUPWIFISELECTED == 'true' && -z $BACKUPFILEBLE ]]; then
          echo -e 'No bluetooth backup file selected! Now processing the selected wifi file'
        else
          echo -e 'The selected file do not exist, nothing was done ...'
        fi
      fi
      echo -e '\e[33mDone\e[0m'
      exit 130
    else
      echo -e '...Nothing happend'
      exit 130
    fi
  elif [[ $ROPTION == '1' ]]; then
    echo -e '\e[34m[*]      \e[32mRestoring Data                       \e[34m[*]\e[0m'
    COUNTFILES=$(ls $LOCAT/wififinder/backups | wc -l)
    prog_setup $COUNTFILES "#"
    if [[ ! -f $LOCAT'/wififinder/sorted_macs.txt' ]]; then
      touch $LOCAT'/wififinder/sorted_macs.txt'
    fi
    for FILENAME in $LOCAT/wififinder/backups/*.csv; do
      i=$((i+1))
      touch $LOCAT/wififinder/tmp.txt
      grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}" $FILENAME >> $LOCAT'/wififinder/tmp.txt'
      while IFS= read -r LINE; do
        if ! grep -Fxq $LINE $LOCAT/wififinder/sorted_macs.txt; then
          echo $LINE >> $LOCAT/wififinder/sorted_macs.txt
        fi
      done < $LOCAT'/wififinder/tmp.txt'
      rm $LOCAT'/wififinder/tmp.txt'
      prog_update $i
    done
    echo -e '\n\e[33mDone\e[0m'
    exit 130
  fi
elif [[ $CONT == '5' ]]; then
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
echo -e '\e[33mDone\e[0m'


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
eval mv $LOCAT/wififinder/WIFICapture-01.csv $LOCAT/wififinder/backups/WIFICapture-$actualtime.csv $VERB2
sleep 1
echo -e '\e[33mDone\e[0m'


#Installing dependencies
echo -e '\e[34m[*]      \e[32mInstalling dependencies			\e[34m[*]\e[0m'
if [[ -x "$(command -v apk)" ]];       then eval apk add --no-cache aircrack-ng -y $VERB1 && apk add --no-chache python3-pip -y $VERB1
elif [[ -x "$(command -v apt-get)" ]]; then eval apt install aircrack-ng -y $VERB1 && eval apt install python3-pip -y $VERB1
elif [[ -x "$(command -v dnf)" ]];     then eval dnf install aircrack-ng -y $VERB1 && eval dnf install python3-pip -y $VERB1
elif [[ -x "$(command -v zypper)" ]];  then eval zypper install aircrack-ng -y $VERB1 && eval zypper install python3-pip -y $VERB1
else echo 'FAILD TO INSTALL PACKAGE: Package manager not found. You must manually install: aircrack-ng'
fi
eval 
eval pip3 install -U -v Flask $VERB2
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
  nohup airodump-ng --berlin 60000 -w $LOCAT/wififinder/WIFICapture --channel 1-13,36-165 --write-interval 10 --output-format csv $WLAN &>/dev/null &
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
  read -p "Neither wi-fi nor bluetooth scanning is possible. Do you want to start the website anyway(y/n)?" STARTWEB
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
