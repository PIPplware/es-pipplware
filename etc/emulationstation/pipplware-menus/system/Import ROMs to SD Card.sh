#!/bin/bash
source /etc/emulationstation/pipplware-menus/system/functions.inc

###Joystick Support###
enable_joystick

###Import ROMs Main Menu###
dialog --title "Import ROMs to SD Card" --yesno "This will copy all your ROMs previously exported to an USB device, back to your SD CARD.\n\nDo you want to proceed?" 12 56
case $? in
        0)
          DRIVE=$(selectDrive 1)
          if [ ! -z "$DRIVE" ]; then
            import_roms "$DRIVE"
	  else
	    dialog --title "Import ROMs to SD Card" --msgbox "No USB storage device found!\n\nPlease insert an USB storage device and try again." 12 56
          fi
        ;;
esac
kill_joystick
clear
###End of Import ROMs Main Menu###
