#!/bin/bash

##Global needed things
#get current path
path=$(pwd)

#Progressbar constructor
progress_setup() {
  # Progress bar variables
  progress_percent=$1
  progress_symbol="$2"

  progress_width=96
  progress_delimiter=$progress_percent
  while [ $(($progress_width + 20)) -gt $(tput cols) ]; do
    progress_width=$(($progress_width / 2))
    progress_delimiter=$(($progress_delimiter * 2))
  done

  progress_count=$progress_width
  while [ $1 -lt $progress_count ]; do
    progress_delimiter=$(($progress_delimiter * 2))
    progress_symbol="$progress_symbol$progress_symbol"
    progress_count=$(($progress_count / 2))
  done

  progress_bar=""
  progress_completion_old=0

  printf "\033[1;032mProgress:\033[0m\033[s [\033[${progress_width}C] 0%%"
  progress_width=$(($progress_width + 1))
}

progress_update() {
  progress_count=$(($1 * 100))
  progress_completion=$(($progress_count / $progress_percent))

  if [ $progress_completion -ne $progress_completion_old ]; then
    if [ $progress_completion -lt 101 ]; then
      progress_bar=$(printf "%0.s${progress_symbol}" $(seq -s " " 1 $(($progress_count / $progress_delimiter))))
    else
      progress_completion=100
      progress_bar=$(printf "%0.s${progress_symbol}" $(seq -s " " 1 $(($((progress_percent * 100)) / progress_delimiter))))
    fi
    progress_completion_old=$progress_completion
  fi

  printf "\033[u [$progress_bar\033[u \033[${progress_width}C] $progress_completion%%"
}

#Stop Scanning
stop_scanning() {
  echo -e '\e[34m[*]      \e[32mStop scanning                   \e[34m[*]\e[0m'
  #stoping the cronjob
  sed -i '/all_in_one.sh/d' /var/spool/cron/crontabs/root
  #stop wi-fi scanning
  eval pkill -e -f airodump-ng $verbose1
  #stop flask
  eval pkill -e -f flask $verbose1
  #backup and move data
  if [[ -f $path/wififinder/WIFICapture-01.csv ]]; then
    actualtime=$(date +%T)
    mv $path/wififinder/WIFICapture-01.csv $path/wififinder/backups/WIFICapture-$actualtime.csv
  fi
  echo -e '\e[33mDone'
}

##intro
echo -e '     _            _                                  _            '
echo -e '    | |          (_)                                | |           '
echo -e '  __| | _____   ___  ___ ___    ___ ___  _   _ _ __ | |_ ___ _ __ '
echo -e ' / _` |/ _ \ \ / / |/ __/ _ \  / __/ _ \| | | | '"' _\| __/ _ \ '"'__|   '
echo -e '| (_| |  __/\ V /| | (_|  __/ | (_| (_) | |_| | | | | ||  __/ |   '
echo -e ' \__,_|\___| \_/ |_|\___\___|  \___\___/ \__,_|_| |_|\__\___|_|   '
echo -e ''
echo -e ''
echo -e ''
echo -e '\e[34m[*]	\e[32mDevice Counter							\e[34m[*]'
echo -e '\e[34m[*]	\e[32mVersion : 1.0 							\e[34m[*]'
echo -e '\e[34m[*]	\e[32mReport Bugs : https://github.com/inflac/Device-Counter/issues	\e[34m[*]'
echo -e '\e[34m[*]	\e[32mCreated By : \e[33mInflac						\e[34m[*]'
echo -e '\e[34m[*]	\e[32mBased on '"'\e[36mAircrack-ng'"' \e[32m& '"'\e[36mBlue Control'"'				\e[34m[*]'
echo -e ''
echo -e 'The Script will do the following things:'
echo -e '--> Install aircrack-ng, flask and python3-pip'
echo -e '--> Change permissions of the files in the folder "device_counter"'
echo -e '--> Edit content of the files in the folder "device_counter"'
echo -e '--> Setup Cronjob for all_in_one.sh'
echo -e ''

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
read -p 'Enter a number:' main_menu_option
if [[ $main_menu_option == '0' ]]; then
  echo 'Starting the full setup'
  verbose1='>/dev/null'
  verbose2='&>/dev/null'
elif [[ $main_menu_option == '1' ]]; then
  verbose1=''
  verbose2=''
  echo 'Starting the full setup in verbose mode'
elif [[ $main_menu_option == '2' ]]; then
  stop_scanning
  sleep 1
  exit 130
elif [[ $main_menu_option == '3' ]]; then
  echo -e '\e[34m[*]      \e[32mAnalyse Data                       \e[34m[*]\e[0m'
  #Analyze the MAC addresses based on the prefix
  read -p 'Enter the name of the file you would like to analys(../device_counter/):' analyse_file_to_analyse
  if [[ ! -f $path/$analyse_file_to_analyse  ]]; then
    echo -e 'File not found, nothing happend...'
    exit 130
  fi
  read -p 'Output the analyzed data to a file(y/n)?' analyse_output_check
  if [[ $analyse_output_check == 'Y' || $analyse_output_check == 'y' ]]; then
    actualtime=$(date +%T)
    touch $path/analyse_result_$actualtime.txt
    analyse_output_location=">>$path/analyse_result_$actualtime.txt"
  else
    analyse_output_location='>/dev/null'
  fi
  line=1
  error='false'
  count_lines=$(cat $path/$analyse_file_to_analyse | wc -l)
  progress_setup $count_lines "#"
  while read macs; do
    brand=$(grep ${macs::8} mac-vendors-export.csv)
    if [[ -z $brand ]]; then
      brand='\e[31mno vendor found - this looks like the MAC is not valid.\e[0m'
    fi

    #check uniq/locally administrated(7th-bit)
    first_byte=${macs:1:1}
    managed='        \e[31mERROR\e[0m        '
    if [[ $first_byte == '0' || $first_byte == '1' || $first_byte == '4' || $first_byte == '5' || $first_byte == '8' || $first_byte == '9' || $first_byte == 'C' || $first_byte == 'c' || $first_byte == 'D' || $first_byte == 'd' ]]; then
      managed='uniq                 '
    elif [[ $first_byte == '2' || $first_byte == '3' || $first_byte == '6' || $first_byte == '7' || $first_byte == 'A' || $first_byte == 'a' || $first_byte == 'B' || $first_byte == 'b' || $first_byte == 'E' || $first_byte == 'e' || $first_byte == 'F' || $first_byte == 'f' ]]; then
      managed='locally administrated'
    else
      error='true'
    fi

    #check unicast/multicast(8th-bit)
    cast='  \e[31mERROR\e[0m  '
    if [[ $first_byte == '0' || $first_byte == '2' || $first_byte == '4' || $first_byte == '6' || $first_byte == '8' || $first_byte == 'A' || $first_byte == 'a' || $first_byte == 'C' || $first_byte == 'c' || $first_byte == 'E' || $first_byte == 'e' ]]; then
      cast='unicast  '
    elif [[ $first_byte == '1' || $first_byte == '3' || $first_byte == '5' || $first_byte == '7' || $first_byte == '9' || $first_byte == 'B' || $first_byte == 'b' || $first_byte == 'D' || $first_byte == 'd' || $first_byte == 'F' || $first_byte == 'f' ]]; then
      cast='multicast'
    else
      error='true'
    fi

    #analysis output
    lenmac=${#macs}
    if [[ -z $first_byte ]]; then
      eval echo -e "\e[31mERROR: whitespace detected - can not continue! Please remove whitespace from document(line: $line)\e[0m" $analyse_output_location
    elif [[ $lenmac -gt 17 || $lenmac -lt 17 || $error == 'true' ]]; then
      eval echo -e "\e[31m$macs\e[0m |         \e[31mERROR\e[0m         |   \e[31mERROR\e[0m   | $brand\e[0m" $analyse_output_location
    else
      eval echo -e "$macs \| $managed \| $cast \| ${brand@Q}" $analyse_output_location
    fi

    line=$((line+1))
    if [[ $analyse_output_check == "Y" || $analyse_output_check == "y" ]]; then
      progress_update $line
    else
      echo -e "$macs | $managed | $cast | $brand"
    fi
    done <$analyse_file_to_analyse
  exit 130
elif [[ $main_menu_option == '4' ]]; then
  #restore Data
  read -p 'Active Scans will get terminated! Continue(y/n)?' restore_accept_stop_scanning
  if [[ "$restore_accept_stop_scanning" -ne "Y" || "$restore_accept_stop_scanning" -ne "y" ]]; then
    echo -e 'You can only restore data when no scan is running'
    exit 130
  else
    stop_scanning
  fi
  echo -e '\e[0m|---------------------------------------|  '
  echo -e ' Restore Main Menue:                            '
  echo -e ' \e[34m[0]\e[0m Choose a backup file            '
  echo -e ' \e[34m[1]\e[0m Unite all backup files          '
  echo -e '\e[0m|---------------------------------------|  '
  read -p 'Enter a number:' restore_main_menu_option
  if [[ $restore_main_menu_option == '0' ]]; then
    read -p 'Data in the sorted_macs.txt files will be overwritten. Want to proceed(y/n)?' CHECK
    if [[ $CHECK == 'y' || $CHECK == 'Y' ]]; then
      echo -e '\e[34m[*]      \e[32mRestoring Data                       \e[34m[*]\e[0m'
      restore_wifi_backupfile_selected='false'
      read -p 'Name of backup file [WIFI]:' restore_backupfile_wifi
      echo $path'/wififinder/'$restore_backupfile_wifi
      if [[ -f $path'/wififinder/backups/'$restore_backupfile_wifi ]]; then
        if [[ -s $path'/wififinder/backups/'$restore_backupfile_wifi ]]; then
          restore_wifi_backupfile_selected='true'
          rm -f $path'/wififinder/sorted_macs.txt' && touch $path'/wififinder/sorted_macs.txt'
          grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}" $path'/wififinder/backups/'$restore_backupfile_wifi >> $path'/wififinder/sorted_macs.txt'
        else
          echo -e 'The selected file is empty, nothing was done...'
        fi
      else
        echo -e 'The selected file do not exist, nothing was done ...'
      fi
      read -p 'Name of backup file [BLUETOOTH]:' restore_backupfile_bluetooth
      if [[ -f $path'/btfinder/backups/'$restore_backupfile_bluetooth ]]; then
        if [[ -s $path'/btfinder/backups'$restore_backupfile_bluetooth ]]; then
          rm -f $path'/btfinder/sorted_macs.txt' && touch $path'/btfinder/sorted_macs.txt'
          grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}" $restore_backupfile_bluetooth >> $path'/btfinder/sorted_macs.txt'
        else
          if [[ $restore_wifi_backupfile_selected == 'true' && -z $restore_backupfile_bluetooth ]]; then
            echo -e 'No bluetooth backup file selected! Now processing the selected wifi file'
          else
            echo -e 'The selected file is empty, nothing was done...'
          fi
        fi
      else
        if [[ $restore_wifi_backupfile_selected == 'true' && -z $restore_backupfile_bluetooth ]]; then
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
  elif [[ $restore_main_menu_option == '1' ]]; then
    echo -e '\e[0m|---------------------------------------|  '
    echo -e ' Unite Backup Menue:                            '
    echo -e ' \e[34m[0]\e[0m All Wifi Backups                '
    echo -e ' \e[34m[1]\e[0m All Bluetooth Backups           '
    echo -e ' \e[34m[2]\e[0m Bluetooth and Wifi              '
    echo -e '\e[0m|---------------------------------------|  '
    read -p 'Choose a number:' restore_unite_menu_option
    if [[ $restore_unite_menu_option == '0' || $restore_unite_menu_option == '2' ]]; then
      if [[ ! -d $path/wififinder/backups ]]; then
        echo -e 'No backup folder found, run a scan befor restoring data. Nothing happend...'
        exit 130
      fi
      countfiles=$(ls $path/wififinder/backups | wc -l)
      if [[ $countfiles == '0' ]]; then
        echo -e 'No wifi backup found in /wififinder/backups. Nothing happend...'
        exit 130
      fi

      if [[ ! -f $path'/wififinder/sorted_macs.txt' ]]; then
        touch $path'/wififinder/sorted_macs.txt'
      fi

      if [[ -f $path/wififinder/tmp.txt ]]; then
        echo -e 'Detected a file "tmp.txt". This name is normaly used in the restore process of the device counter.'
        echo -e 'If you want to continue, the data in "tmp.txt" will get overwritten.'
	read -p 'Continue(y/n)?' restore_delete_tmp_check
	if [[ $restore_delete_tmp_check -ne "Y" || $restore_delete_tmp_check -ne "y" ]]; then
	  echo -e 'To unite all data this script needs to create a file wififinder/tmp.txt.'
	  echo -e 'This conflicts with the already existing file wififinder/tmp.txt'
	  exit 130
	else
	  rm $path/wififinder/tmp.txt
	fi
      fi

      progress_setup $countfiles "#"
      for restore_backup_file in $path/wififinder/backups/*.csv; do
        i=$((i+1))
        touch $path/wififinder/tmp.txt
        grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}" $restore_backup_file >> $path'/wififinder/tmp.txt'
        while IFS= read -r restore_line_of_backup; do
          if ! grep -Fxq $restore_line_of_backup $path/wififinder/sorted_macs.txt; then
            echo $restore_line_of_backup >> $path/wififinder/sorted_macs.txt
          fi
        done < $path'/wififinder/tmp.txt'
        rm $path'/wififinder/tmp.txt'
        progress_update $i
      done
      echo -e '\n\e[33mDone\e[0m'
      exit 130
    fi
    if [[ $restore_unite_menu_option == '1' || $restore_unite_menu_option == '2' ]]; then
      if [[ ! -d $path/btfinder/backups ]]; then
        echo -e 'No backup folder found, run a scan befor restoring data. Nothing happend...'
        exit 130
      fi
      countfiles=$(ls $path/btfinder/backups | wc -l)
      if [[ $countfiles == '0' ]]; then
        echo -e 'No bluetooth backup found in /btfinder/backups. Nothing happend...'
        exit 130
      fi

      if [[ ! -f $path'/btfinder/sorted_macs.txt' ]]; then
        touch $path'/btfinder/sorted_macs.txt'
      fi

      if [[ -f $path/btfinder/tmp.txt ]]; then
        echo -e 'Detected a file "tmp.txt". This name is normaly used in the restore process of the device counter.'
        echo -e 'If you want to continue, the data in "tmp.txt" will get overwritten.'
        read -p 'Continue(y/n)?' restore_delete_tmp_check
        if [[ $restore_delete_tmp_check -ne "Y" || $restore_delete_tmp_check -ne "y" ]]; then
          echo -e 'To unite all data this script needs to create a file btfinder/tmp.txt.'
          echo -e 'This conflicts with the already existing file btfinder/tmp.txt'
          exit 130
        else
          rm $path/btfinder/tmp.txt
        fi
      fi

      progress_setup $countfiles "#"
      for restore_backup_file in $path/btfinder/backups/*.txt; do
        i=$((i+1))
        touch $path/btfinder/tmp.txt
        grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}" $restore_backup_file >> $path'/btfinder/tmp.txt'
        while IFS= read -r restore_line_of_backup; do
          if ! grep -Fxq $restore_line_of_backup $path/btfinder/sorted_macs.txt; then
            echo $restore_line_of_backup >> $path/btfinder/sorted_macs.txt
          fi
        done < $path'/btfinder/tmp.txt'
        rm $path'/btfinder/tmp.txt'
        progress_update $i
      done
      echo -e '\n\e[33mDone\e[0m'
      exit 130
    fi
  fi
elif [[ $main_menu_option == '5' ]]; then
  read -p 'Active Scans will get terminated! Continue(y/n)?' restore_accept_stop_scanning
  if [[ $restore_accept_stop_scanning != "Y" || $restore_accept_stop_scanning != "y" ]]; then
    echo -e 'You can only restore data when no scan is running'
    exit 130
  fi
  stop_scanning
  read -p 'Are you sure that you want to clear all captured data(y/n)?' clear_data_check
  if [[ $clear_data_check == 'y' ]]; then
    echo -e '\e[34m[*]      \e[32mClearing all captured Data                   \e[34m[*]\e[0m'
    #Remove backups
    if [[ -d $path'/btfinder/backups' ]]; then
      rm -r -f $path/btfinder/backups/*.txt
      rm $path/btfinder/sorted_macs.txt && touch $path/btfinder/sorted_macs.txt
    fi
    if [[ -d $path'/wififinder/backups' ]]; then
      rm -r -f $path/wififinder/backups/*.csv
      rm $path/wififinder/sorted_macs.txt && touch $path/wififinder/sorted_macs.txt
    fi
    #Clear countedmacs.txt
    sed -i -e 1c'0' $path/countedmacs.txt
    sleep 1
    echo -e '\e[33mDone'
    exit 130
  else
    echo -e '...Nothing happend'
    exit 130
  fi
else
  echo -e '  _   _  ____   ____ _______   _   _  ____   ____ _______ '
  echo -e ' | \ | |/ __ \ / __ \__   __| | \ | |/ __ \ / __ \__   __|'
  echo -e ' |  \| | |  | | |  | | | |    |  \| | |  | | |  | | | |   '
  echo -e ' | . ` | |  | | |  | | | |    | . ` | |  | | |  | | | |   '
  echo -e ' | |\  | |__| | |__| | | |    | |\  | |__| | |__| | | |   '
  echo -e ' |_| \_|\____/ \____/  |_|    |_| \_|\____/ \____/  |_|   '
  exit 130
fi

#Stop running scans
echo -e '\e[34m[*]      \e[32mKill running scans                             \e[34m[*]\e[0m'
eval pkill -e -f airodump-ng $verbose1
eval pkill -e -f flask $verbose1
sleep 1
echo -e '\e[33mDone\e[0m'


#Adjusting permissions
echo -e '\e[34m[*]      \e[32mAdjusting permissions                          \e[34m[*]\e[0m'
eval chmod -v +x all_in_one.sh $verbose1
eval chmod -v +x count_sorted.py $verbose1
sleep 1
echo -e '\e[33mDone\e[0m'


##Adjusting path in files
echo -e '\e[34m[*]      \e[32mAdjusting path in files                        \e[34m[*]\e[0m'
#Get path to update
eval echo -e Using $path as the path to the device_counter folder $verbose1

#Read path of the all_in_one.sh file(line2).
CURRPATH=$(sed '2q;d' all_in_one.sh)
CURRPATH=${CURRPATH:1}

#Update current path with new path in all_in_one.sh
eval sed -i 's,$CURRPATH,$path,' all_in_one.sh $verbose2
eval sed -i 's,$CURRPATH,$path,' count_sorted.py $verbose2
eval sed -i 's,$CURRPATH,$path,' web/myapp.py $verbose2
sleep 1
echo -e '\e[33mDone'


#Check for backupfolder
echo -e '\e[34m[*]      \e[32mCheck for backupfolder                         \e[34m[*]\e[0m'
if ! [[ -d $path'/btfinder/backups' ]];then
   eval mkdir -v $path/btfinder/backups $verbose1;
else
  eval echo -e 'Backupfolder[Wi-Fi] found' $verbose1
fi
if ! [[ -d $path'/wififinder/backups' ]];then
   eval mkdir -v $path/wififinder/backups $verbose1;
else
  eval echo -e 'Backupfolder[Bluetooth] found' $verbose1
fi
sleep 1
echo -e '\e[33mDone'


#Move scan results to backups
echo -e '\e[34m[*]      \e[32mMove scan results                              \e[34m[*]\e[0m'
actualtime=$(date +%T)
eval mv $path/wififinder/WIFICapture-01.csv $path/wififinder/backups/WIFICapture-$actualtime.csv $verbose2
sleep 1
echo -e '\e[33mDone\e[0m'


#Installing dependencies
echo -e '\e[34m[*]      \e[32mInstalling dependencies			\e[34m[*]\e[0m'
if [[ -x "$(command -v apk)" ]];       then eval apk add --no-cache aircrack-ng -y $verbose1 && apk add --no-chache python3-pip -y $verbose1
elif [[ -x "$(command -v apt-get)" ]]; then eval apt install aircrack-ng -y $verbose2 && eval apt install python3-pip -y $verbose2
elif [[ -x "$(command -v dnf)" ]];     then eval dnf install aircrack-ng -y $verbose1 && eval dnf install python3-pip -y $verbose1
elif [[ -x "$(command -v zypper)" ]];  then eval zypper install aircrack-ng -y $verbose1 && eval zypper install python3-pip -y $verbose1
else echo 'FAILD TO INSTALL PACKAGE: Package manager not found. You must manually install: aircrack-ng'
fi
eval 
eval pip3 install -U -v Flask $verbose2
echo -e '\e[33mDone\e[0m'


#Test if scanning with wi-fi is possible
startwifiscan='false'
echo -e '\e[34m[*]      \e[32mTesting wi-fi					\e[34m[*]\e[0m'
wifi_scanning_check=$(ip link show | awk '{print $2}' | grep 'wlan' | sort -k 1,1 | tail -1)
if [[ $wifi_scanning_check == '' ]]; then
  echo -e '\e[31mWARNING: Scanning with Wi-Fi is not possible!';
  echo -e 'Note: If you are only scanning with Bluetooth, you can ignore this message.';
  eval echo -e 'Reason: It wasnt possible to detect any Wi-Fi adapter. Please try to detache or deactivate the adapter and then reattach  or reactivate it.' $verbose1;
  eval echo -e 'Hint: If you are sure that Wi-Fi scanning should be possible, you can try running the wifi_start_scan.sh skript.' $verbose1;
  eval echo -e 'Do not close the terminal in which you started the skript, as it needs to run the whole time you want to scan for devices.' $verbose1;
  sleep 1
else
  eval echo -e 'using interface: $wifi_scanning_check' $verbose1;
  startwifiscan="true"
fi
echo -e '\e[33mDone\e[0m'


#Start scanning with wi-fi
echo -e '\e[34m[*]      \e[32mStart scanning with wi-fi                      \e[34m[*]\e[0m'
if [[ $startwifiscan == 'true' ]]; then
  wifi_interface=$(airmon-ng | awk '{print $2}' | grep 'wlan' | sort -k 1,1 | tail -1)
  eval airmon-ng --verbose start $wifi_interface $verbose2
  sleep 5
  nohup airodump-ng --berlin 60000 -w $path/wififinder/WIFICapture --channel 1-13,36-165 --write-interval 10 --output-format csv $wifi_interface &>/dev/null &
else
  echo -e '\e[31mBecause Scanning with Wi-Fi is not possible as detected above'
  echo -e 'no scann was initialized!\e[0m'
  sleep 1
fi
echo -e '\e[33mDone\e[0m'


#Test if scanning with bluetooth is possible
echo -e '\e[34m[*]      \e[32mTesting bluetooth				\e[34m[*]\e[0m'
bluetooth_scanning_check=$(dmesg | grep -i Bluetooth)
alish_bluetooth_scanning_stauts=$(sed -n 3p all_in_one.sh)
if [[ $bluetooth_scanning_check = '' ]]; then
  if [[ ${alish_bluetooth_scanning_stauts::1} != '#' ]]; then
    sed -i '3s/^/#/' all_in_one.sh;
  fi
  echo -e '\e[31mWARNING: Scanning with Bluetooth is not possible!';
  echo -e 'Note: If you are only scanning with Wi-Fi, you can ignore this message.';
  eval echo -e 'Reason: It wasnt possible to detect any Bluetooth adapter. Please try to detache or deactivate the adapter and then reattach  or reactivate it.' $verbose1;
  eval echo -e 'Function: The line for scanning with bluetooth in all_in_one.sh was deactivated by adding a \"#\" at the beginning of the line.' $verbose1;
  eval echo -e 'If you want to debug the issue by yourself, you can try to manually reactivate the line by removing the \"#\"' $verbose1;
  startblescan='false'
else
  if [[ ${alish_bluetooth_scanning_stauts::1} == '#' ]]; then
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
  eval echo -e 'Reason: Scanning with wifi and bluetooth is not possible, so there is no use for the all_in_one.sh skript.' $verbose1;
else
  #Removing old cronjob(The sed command realy removes every line with the matching string in it!)
  sed -i '/all_in_one.sh/d' /var/spool/cron/crontabs/root

  #Setting up new cronjob
  crontab -l > allinone
  echo '* * * * * '$path'/all_in_one.sh' >> allinone
  eval crontab allinone $verbose2
  rm allinone
fi
  sleep 1
echo -e '\e[33mDone\e[0m'

echo -e '\e[34m[*]      \e[32mStart the web application                      \e[34m[*]\e[0m'
if [[ $startwifiscan == 'false' && $startblescan == 'false' ]]; then
  read -p "Neither wi-fi nor bluetooth scanning is possible. Do you want to start the website anyway(y/n)?" start_website
  if [[ $start_website == 'n' || $start_website == 'N' ]]; then
    echo -e 'Website not launched'
  elif [[ $start_website == 'y' || $start_website == 'Y' ]]; then
    cd $path/web
    export FLASK_APP=myapp
    export FLASK_ENV=development
    nohup flask run &>/dev/null &
    cd $path
    eval echo -e 'Website launched' $verbose1;
  else
    echo -e 'False answer, website was not launched!'
  fi
else
  eval echo -e 'Website launched' $verbose1;
  cd $path/web
  export FLASK_APP=myapp
  export FLASK_ENV=development
  nohup flask run &>/dev/null &
  cd $path
fi
echo -e '\e[33mDone\e[0m'


#Evaluation
if [[ $startwifiscan == 'false' && $startblescan == 'false' ]]; then
  evaluation_status='\e[33mNO SCAN ACTIVE\e[0m'
  spacer='\e[32m##############\e[0m'
elif [[ $startwifiscan == 'true' && $startblescan == 'false' ]]; then
  evaluation_status='\e[33mONLY WIFI SCAN\e[0m'
  spacer='\e[32m##############\e[0m'
elif [[ $startwifiscan == 'false' && $startblescan == 'true' ]]; then
  evaluation_status='\e[33mONLY BLUETOOTH SCAN\e[0m'
  spacer='\e[32m###################\e[0m'
elif [[ $startwifiscan == 'true' && $startblescan == 'true' ]]; then
  evaluation_status='\e[33mBOTH SCANS ACTIVE\e[0m'
  spacer='\e[32m##################\e[0m'
else
  evaluation_status='ERROR'
fi

#Evaluation message
echo -e ''
echo -e ''
echo -e '\e[32m##################|\e[0m'$evaluation_status'\e[32m|###################\e[0m'
if [[ $start_website == 'n' || $start_website == 'N' ]]; then
  echo -e '\e[34mWebsite URL:\e[0m NOT LAUNCHED'
else
  echo -e '\e[34mWebsite URL:\e[0m http://127.0.0.1:5000'
fi
echo -e ''
echo -e ''
echo -e '\e[32m##################\e[0m'$spacer'\e[32m#####################\e[0m'
