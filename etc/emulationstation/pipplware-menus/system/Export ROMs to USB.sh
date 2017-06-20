#!/bin/bash
source /etc/emulationstation/pipplware-menus/system/functions.inc

###Joystick Support###
enable_joystick

###Export ROMs Main Menu###
dialog --title "Export ROMs to USB" --yesno "This will copy all your ROMs in your SD CARD to a connected USB device.\n\nDo you want to proceed?" 12 56
case $? in
        0)
          DRIVE=$(selectDrive 1)
          if [ ! -z "$DRIVE" ]; then
            export_roms "$DRIVE"
	  else
	    dialog --title "Export ROMs to USB" --msgbox "No USB storage device found!\n\nPlease insert an USB storage device and try again." 12 56
          fi
        ;;
esac
kill_joystick
clear
###End of Export Roms Main Menu###
