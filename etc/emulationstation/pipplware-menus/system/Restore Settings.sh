#!/bin/bash
source /etc/emulationstation/pipplware-menus/system/functions.inc

###Joystick Support###
enable_joystick

###Restore Settings Main Menu###
dialog --title "Restore Settings" --yesno "This will restore a previously made Backup. WARNING: All your current settings will be overwritten and lost!\n\nDo you want to proceed?" 12 56
case $? in
        0)
          DRIVE=$(selectDrive)
          if [ ! -z "$DRIVE" ]; then
            restore "$DRIVE"
          fi
        ;;
esac
kill_joystick
clear
###End of Restore Settings Main Menu###
