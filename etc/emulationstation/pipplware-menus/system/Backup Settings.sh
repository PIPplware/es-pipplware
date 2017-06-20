#!/bin/bash
source /etc/emulationstation/pipplware-menus/system/functions.inc

###Joystick Support###
enable_joystick

###Backup Settings Main Menu###
dialog --title "Backup Settings" --yesno "This will make a Backup of all your Pipplware settings, configurations and personal files.\n\nDo you want to proceed?" 12 56
case $? in
       	0)
	  DRIVE=$(selectDrive)
          if [ ! -z "$DRIVE" ]; then
            backup "$DRIVE"
          fi
        ;;
esac
kill_joystick
clear
###End of Backup Settings Main Menu###
