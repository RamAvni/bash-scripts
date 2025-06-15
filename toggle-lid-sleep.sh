#!/bin/bash

# This is an "it works on my machine" script.
# Use with caution.

# alias toggle-lid-sleep='sudo /home/$USER/bash-scripts/toggle-lid-sleep.sh'

get-line-number() {
  text=$1
  file_path=$2

  findings=$(sed -n "/${text}/=" ${file_path})
  no_of_findings=$(echo $findings | wc -w)

  # Error Handeling
  if [ $no_of_findings -gt 1 ]; then
    echo "get-line-number(): Found Multiple matches. Should exact to a single line"
    exit 1
  elif [ $no_of_findings -le 0 ]; then
    echo "get-line-number(): Could not find a match"
    exit 1
  fi

  echo ${findings}
}

is-commented() {
  line_number=$1
  file_path=$2

  findings=$(sed -n "${line_number}{/#/p}" ${file_path})

  if [ $findings ]; then
    echo 0
  else
    echo 1
  fi

}

main() {
  file_path=/etc/systemd/logind.conf
  lid_settings_matchers=("HandleLidSwitch=" "HandleLidSwitchExternalPower=" "HandleLidSwitchDocked=")

  for setting in ${lid_settings_matchers[@]}; do
    line_number=$(get-line-number ${setting} ${file_path})
    commented=$(is-commented $line_number ${file_path})

    if [ $commented -eq 0 ]; then
      sed -i "${line_number}s/^#//" ${file_path}
    else
      sed -i "${line_number}s/^/#/" ${file_path}
    fi
  done

  if [ $commented -eq 0 ]; then
    echo "Allowed current lid settings. You should reboot your PC"
  else
    echo "Disabled current lid settings. You should reboot your PC"
  fi
}

main
