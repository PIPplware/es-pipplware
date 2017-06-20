#!/bin/bash
source /etc/emulationstation/pipplware-menus/system/functions.inc

###Joystick Support###
enable_joystick

###Enable / Disable Services###
while true; do
	cmd=(dialog --title "Enable / Disable Services" --menu "Choose the program to enable or disable system services" 12 56 5)
        options=(
                1 "Serman - for systemd services"
                2 "Rcconf - for init.d scripts"
                )
        choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        if [[ -n "$choices" ]]; then
                case $choices in
                1) sudo /usr/bin/python3 /usr/bin/serman --systemctl /bin/systemctl -e ;;
                2) sudo /usr/bin/rcconf ;;
                esac
	else
		break
	fi
done
kill_joystick
clear
###End of Enable / Disable Services Main Menu###
