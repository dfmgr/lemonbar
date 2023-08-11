#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2317
# shellcheck disable=SC2120
# shellcheck disable=SC2155
# shellcheck disable=SC2199
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202207042116-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.pro
# @@License          :  LICENSE.md
# @@ReadME           :  lemonbar.sh --help
# @@Copyright        :  Copyright: (c) 2023 Jason Hempstead, Casjays Developments
# @@Created          :  Tuesday, Apr 25, 2023 20:46 EDT
# @@File             :  lemonbar.sh
# @@Description      :
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  shell/sh
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional functions
__lemonbar() {
  Clock() {
    DATE=$(date "+%m.%d.%y")
    TIME=$(date "+%I:%M")
    echo -e -n "\uf073 ${DATE} \uf017 ${TIME}"
  }

  ActiveWindow() {
    echo -n "$(xdotool getwindowfocus getwindowname)"
  }

  Battery() {
    BATTACPI=$(acpi --battery)
    BATPERC=$(echo "$BATTACPI" | cut -d, -f2 | tr -d '[:space:]')
    if [[ $BATTACPI == *"100%"* ]]; then
      echo -e -n "\uf00c $BATPERC"
    elif [[ $BATTACPI == *"Discharging"* ]]; then
      BATPERC=${BATPERC::-1}
      if [ $BATPERC -le "10" ]; then
        echo -e -n "\uf244"
      elif [ $BATPERC -le "25" ]; then
        echo -e -n "\uf243"
      elif [ $BATPERC -le "50" ]; then
        echo -e -n "\uf242"
      elif [ $BATPERC -le "75" ]; then
        echo -e -n "\uf241"
      elif [ $BATPERC -le "100" ]; then
        echo -e -n "\uf240"
      fi
      echo -e " $BATPERC%"
    elif [[ $BATTACPI == *"Charging"* && $BATTACPI != *"100%"* ]]; then
      echo -e "\uf0e7 $BATPERC"
    elif [[ $BATTACPI == *"Unknown"* ]]; then
      echo -e "$BATPERC"
    fi
  }

  Wifi() {
    WIFISTR=$(iwconfig wlan0 | grep "Link" | sed 's/ //g' | sed 's/LinkQuality=//g' | sed 's/\/.*//g')
    if [ ! -z $WIFISTR ]; then
      WIFISTR=$((${WIFISTR} * 100 / 70))
      ESSID=$(iwconfig wlan0 | grep ESSID | sed 's/ //g' | sed 's/.*://' | cut -d "\"" -f 2)
      if [ $WIFISTR -ge 1 ]; then
        echo -e "\uf1eb ${ESSID} ${WIFISTR}%"
      fi
    fi
  }

  Sound() {
    NOTMUTED=$(amixer sget Master | grep "\[on\]")
    if [ -n "$NOTMUTED" ]; then
      VOL=$(awk -F"[][]" '/dB/ { print $2 }' <(amixer sget Master) | sed 's/%//g')
      if [ $VOL -ge 85 ]; then
        echo -e "\uf028 ${VOL}%"
      elif [ $VOL -ge 50 ]; then
        echo -e "\uf027 ${VOL}%"
      else
        echo -e "\uf026 ${VOL}%"
      fi
    else
      echo -e "\uf026 M"
    fi
  }

  while true; do
    echo -e "%{l}" "%{c}$(ActiveWindow)" "%{r}$(Wifi)  $(Battery)  $(Clock)"
    sleep 0.1s
  done
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Main application
[ -n "$(type -P lemonbar)" ] || { echo "lemonbar is not installed" && exit 1; }
__lemonbar | lemonbar -p -F#FFFFFFFF -B#FF222222 -f "Hack Nerd Font-8" -f FontAwesome-8 >/dev/null 2>&1 &
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# ex: ts=2 sw=2 et filetype=sh
