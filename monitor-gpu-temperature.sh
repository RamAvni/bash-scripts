#!/bin/bash

assign_edges() {
  if [ $1 -gt $peak ]; then
    peak=$1
  elif [ $1 -lt $low ]; then
    low=$1
  fi
}

get_temperature_color() {
  if [ $1 = "reset" ]; then
    echo "\e[0m"
    exit 1
  fi

  if [ $1 -gt 85 ]; then
    echo "\e[0;31m"
  elif [ $1 -gt 60 ]; then
    echo "\e[1;33m"
  elif [ $1 -lt 45 ]; then
    echo "\e[1;34m"
  else
    echo "\e[1;37m"
  fi
}

print_status_message() (
  printf "${peak_color}Peak: ${peak} ${low_color}Low: ${low} ${color_reset}\n"
  printf "After $seconds_passed seconds, GPU's Temperature is: $temp"
)

bye() {
  pink_color="\e[1;35m"
  clear
  printf "${peak_color}Peak: $peak ${low_color}Low: $low ${color_reset}\n"
  printf "${pink_color}Bye! ;) ${color_reset}"
}

function main() {
  seconds_passed=0
  peak=0
  low=0

  color_reset=$(get_temperature_color "reset")
  peak_color=$(get_temperature_color "$peak")
  low_color=$(get_temperature_color "$low")

  trap bye EXIT

  while true; do
    clear
    temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader)
    if [ $low -eq 0 ]; then
      low=$temp
    fi

    assign_edges $temp

    print_status_message

    seconds_passed=$((seconds_passed + 10))
    sleep 10
  done
}

main
