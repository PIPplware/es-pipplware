#!/bin/bash
source /etc/emulationstation/pipplware-menus/system/functions.inc
scriptdir="/home/pi/RetroPie-Setup/"
__backtitle="PiPplware Tools Main Menu"

###Joystick Support###
enable_joystick

###Sub-Menus###
change_es_emulators() {
cmd=(dialog --title "$__backtitle" --menu "Select which device you want to load ROMs from:" 15 76 6)
options=(
        1 "Select drive where ROMs are stored"
        2 "Restore original PiPplware ES Systems config"
        )
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
if [[ -n "$choices" ]]; then
        case $choices in
        1)
	        DRIVE=$(selectDrive)
		if [ -d "$DRIVE/RetroPie" ]; then
			sudo cp /etc/emulationstation/es_systems.cfg /etc/emulationstation/es_systems.cfg.backup
			sudo sed -i -e "s|<path>.*RetroPie|<path>$DRIVE/RetroPie|" /etc/emulationstation/es_systems.cfg
			if [ -f "/opt/retropie/configs/all/emulationstation/es_systems.cfg" ]; then
				cp /opt/retropie/configs/all/emulationstation/es_systems.cfg /opt/retropie/configs/all/emulationstation/es_systems.cfg.backup
				sed -i -e "s|<path>.*RetroPie|<path>$DRIVE/RetroPie|" /opt/retropie/configs/all/emulationstation/es_systems.cfg
			fi
			dialog --msgbox "ROMs will be load from:\n$DRIVE/RetroPie/roms\n\nPlease restart ES or reboot your system for changes to take effect!" 11 56
		else
                	dialog --msgbox "Error! No RetroPie folder found!\n\nPlease run Export ROMs to USB first or select a drive containing a RetroPie folder." 11 56
		fi
                ;;
        2)
		dialog --title "Restore original PiPplware ES Systems config" --yesno "WARNING! Any user installed emulators/ports/etc will not be removed but they will dissapear from ES as well as any custom configuration made to ES systems!\n\nDo you want to proceed?" 12 56
		case $? in
			0)
			sudo cp /etc/emulationstation/es_systems.cfg.original /etc/emulationstation/es_systems.cfg
			if [ -f "/opt/retropie/configs/all/emulationstation/es_systems.cfg" ]; then
				cp /etc/emulationstation/es_systems.cfg.original /opt/retropie/configs/all/emulationstation/es_systems.cfg
			fi
                	dialog --msgbox "Original PiPplware Systems config restored!.\n\nPlease restart ES or reboot your system for changes to take effect!" 11 56
			;;
		esac
		;;
        esac
fi
}

hide_esmenus() {
cmd=(dialog --title "$__backtitle" --menu "Enable/Disable EmulationStation Menus:" 15 76 6)
options=(
        1 "Disable PiPplware menu"
        2 "Disable System menu"
        3 "Disable RetroPie menu"
	4 "Enable all menus"
        )
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
if [[ -n "$choices" ]]; then
        case $choices in
        1)
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"pipplware\" \"pipplware\""
                dialog --msgbox "PiPplware Menu disabled!\n\nPlease restart ES or reboot your system for changes to take effect!" 9 55
                ;;

        2)
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"system\" \"system\""
                dialog --msgbox "System Menu disabled!\n\nPlease restart ES or reboot your system for changes to take effect!" 9 56
                ;;

        3)
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"retropie\" \"retropie\""
                dialog --msgbox "System Menu disabled!\n\nPlease restart ES or reboot your system for changes to take effect!" 9 56
                ;;

	4)
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"pipplware\" \"pipplware\""
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"retropie\" \"retropie\""
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"system\" \"system\""
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _add_system_emulationstation \"Pipplware\" \"aaaapipplware\" \"/etc/emulationstation/pipplware-menus/pipplware\" \".sh .SH\" \"%ROM%\" \"pc\" \"pipplware\""
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _add_system_emulationstation \"RetroPie\" \"zzzzretropie\" \"/home/pi/RetroPie/retropiemenu\" \".rp .sh\" \"sudo /home/pi/RetroPie-Setup/retropie_packages.sh retropiemenu launch %ROM% &lt;/dev/tty &gt;/dev/tty\" \"\" \"retropie\""
                sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _add_system_emulationstation \"System\" \"aaabsystem\" \"/etc/emulationstation/pipplware-menus/system\" \".sh .SH\" \"%ROM%\" \"pc\" \"system\""
                sudo sed -i -e "s/aaaapipplware/pipplware/g" /etc/emulationstation/es_systems.cfg
                sudo sed -i -e "s/zzzzretropie/retropie/g" /etc/emulationstation/es_systems.cfg
                sudo sed -i -e "s/aaabsystem/system/g" /etc/emulationstation/es_systems.cfg
                dialog --msgbox "All menus enabled!\n\nPlease restart ES or reboot your system for changes to take effect!" 9 56
                ;;
        esac
fi
}

change_pip_aspect_ratio() {
cmd=(dialog --title "$__backtitle" --menu "Set Emulation Station aspect ratio (not emulators/games):" 15 76 6)
options=(
        1 "Set to 16:9, default"
        2 "Set to 16:10"
        3 "Set to 4:3"
        )
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
if [[ -n "$choices" ]]; then
        case $choices in
        1)
                sudo cp /etc/emulationstation/themes/pipplware/pipplware/art/pipplware_art_16_9.jpg /etc/emulationstation/themes/pipplware/pipplware/art/pipplware_art.jpg
		sudo cp /etc/emulationstation/themes/dark/pipplware/art/pipplware_art_16_9.jpg /etc/emulationstation/themes/dark/pipplware/art/pipplware_art.jpg
		sudo cp /opt/retropie/supplementary/splashscreen/pipplware/pipplware_splash_16_9.jpg /opt/retropie/supplementary/splashscreen/pipplware/pipplware_splash.jpg
		sudo cp /usr/share/xfce4/backdrops/pipplware_background_16_9.jpg /usr/share/xfce4/backdrops/pipplware_background.jpg
		dialog --msgbox "PiPplware aspect ratio set to 16:9\n\nPlease reboot system for changes to take effect!" 9 55
		;;
        2)
                sudo cp /etc/emulationstation/themes/pipplware/pipplware/art/pipplware_art_16_10.jpg /etc/emulationstation/themes/pipplware/pipplware/art/pipplware_art.jpg
                sudo cp /etc/emulationstation/themes/dark/pipplware/art/pipplware_art_16_10.jpg /etc/emulationstation/themes/dark/pipplware/art/pipplware_art.jpg
		sudo cp /opt/retropie/supplementary/splashscreen/pipplware/pipplware_splash_16_10.jpg /opt/retropie/supplementary/splashscreen/pipplware/pipplware_splash.jpg
                sudo cp /usr/share/xfce4/backdrops/pipplware_background_16_10.jpg /usr/share/xfce4/backdrops/pipplware_background.jpg
		dialog --msgbox "PiPplware aspect ratio set to 16:10\n\nPlease reboot system for changes to take effect!" 9 56
		;;
        3)
                sudo cp /etc/emulationstation/themes/pipplware/pipplware/art/pipplware_art_4_3.jpg /etc/emulationstation/themes/pipplware/pipplware/art/pipplware_art.jpg
		sudo cp /etc/emulationstation/themes/dark/pipplware/art/pipplware_art_4_3.jpg /etc/emulationstation/themes/dark/pipplware/art/pipplware_art.jpg
		sudo cp /opt/retropie/supplementary/splashscreen/pipplware/pipplware_splash_4_3.jpg /opt/retropie/supplementary/splashscreen/pipplware/pipplware_splash.jpg
                sudo cp /usr/share/xfce4/backdrops/pipplware_background_4_3.jpg /usr/share/xfce4/backdrops/pipplware_background.jpg
                dialog --msgbox "PiPplware aspect ratio set to 4:3\n\nPlease reboot system for changes to take effect!" 9 56
		;;
        esac
fi
}

disable_pulseaudio() {
cmd=(dialog --title "$__backtitle" --menu "Disable/Enable PulseAudio:" 15 76 6)
options=(
        1 "Disable PulseAudio"
        2 "Enable PulseAudio"
        )
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
if [[ -n "$choices" ]]; then
        case $choices in
        1)
                dialog --title "Disable PulseAudio" --yesno "This will disable PulseAudio in XFCE only and may improve audio sync when in heavy load, like in Chromium.\n\nWARNING: You will loose Bluetooth audio support in XFCE.\n\nDo you want to continue?" 12 56
		case $? in
			0)
			if [ -f "/etc/xdg/autostart/pulseaudio.desktop" ]; then
                                sudo mv /etc/xdg/autostart/pulseaudio.desktop /etc/xdg/autostart/pulseaudio.desktop.bak
				dialog --msgbox "PulseAudio disabled!" 9 56
			else
				dialog --msgbox "PulseAudio already disabled!" 9 56
                        fi
			dialog --title "Remove PulseAudio" --yesno "Do you want to completely remove PulseAudio?\n\nWARNING: You will loose bluetooth audio support also in Kodi!\n\nOnly do this if you are experiencing problems with external sound cards/DACs!" 12 56
				case $? in
					0)
					sudo apt-get -y remove pulseaudio*
					dialog --msgbox "PulseAudio removed!" 9 56
					;;
				esac
                	;;
		esac
		;;
        2)
                dialog --title "Enable PulseAudio" --yesno "This will enable PulseAudio again.\n\nDo you want to continue?" 12 56
		case $? in
			0)
			sudo apt-get install -y pulseaudio pulseaudio-module-bluetooth
			if [ -f "/etc/xdg/autostart/pulseaudio.desktop.bak" ]; then
                                sudo mv /etc/xdg/autostart/pulseaudio.desktop.bak /etc/xdg/autostart/pulseaudio.desktop
                                dialog --msgbox "PulseAudio enabled!" 9 56
                        else
                                dialog --msgbox "PulseAudio already enabled!" 9 56
                        fi
			;;
		esac
		;;
        esac
fi
}

update_retropie() {
dialog --title "Update RetroPie" --yesno "This will update RetroPie-Setup scripts and all currently installed packages from RetroPie. This can take some time depending on many factors.\n\nDo you want to proceed?" 12 56
case $? in
	0)
	sudo cp /boot/config.txt /boot/config.txt.bak
	sudo __nodialog=1 bash /home/pi/RetroPie-Setup/retropie_packages.sh setup updatescript
	sudo __nodialog=1 bash /home/pi/RetroPie-Setup/retropie_packages.sh setup post_update update_packages_setup update
	sudo cp /boot/config.txt.bak /boot/config.txt
	sudo cp /opt/retropie/supplementary/emulationstation.kodi_autostart /opt/retropie/supplementary/emulationstation/emulationstation
	sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"pipplware\" \"pipplware\""
	sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"retropie\" \"retropie\""
	sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _del_system_emulationstation \"system\" \"system\""
	sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _add_system_emulationstation \"Pipplware\" \"aaaapipplware\" \"/etc/emulationstation/pipplware-menus/pipplware\" \".sh .SH\" \"%ROM%\" \"pc\" \"pipplware\""
	sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _add_system_emulationstation \"RetroPie\" \"zzzzretropie\" \"/home/pi/RetroPie/retropiemenu\" \".rp .sh\" \"sudo /home/pi/RetroPie-Setup/retropie_packages.sh retropiemenu launch %ROM% &lt;/dev/tty &gt;/dev/tty\" \"\" \"retropie\""
	sudo /bin/bash -c "source $scriptdir/scriptmodules/supplementary/emulationstation.sh ; _add_system_emulationstation \"System\" \"aaabsystem\" \"/etc/emulationstation/pipplware-menus/system\" \".sh .SH\" \"%ROM%\" \"pc\" \"system\""
	sudo sed -i -e "s/aaaapipplware/pipplware/g" /etc/emulationstation/es_systems.cfg
        sudo sed -i -e "s/zzzzretropie/retropie/g" /etc/emulationstation/es_systems.cfg
	sudo sed -i -e "s/aaabsystem/system/g" /etc/emulationstation/es_systems.cfg
	sudo apt-get install --reinstall es-pipplware
	dialog --msgbox "RetroPie update sucessful!" 9 56
	;;
esac
}

raspbian_programming() {
cmd=(dialog --title "$__backtitle" --menu "Raspbian bundled programming software:" 15 76 6)
options=(
        1 "Install Raspbian bundled programming software"
        2 "Remove Raspbian bundled programming software"
        )
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
if [[ -n "$choices" ]]; then
        case $choices in
        1)
                sudo apt-get install -y bluej greenfoot nodered nodejs scratch squeak-vm squeak-plugins-scratch sonic-pi supercollider wolfram-engine
                dialog --msgbox "Raspbian bundled programming software installed!" 9 56
                ;;
        2)
                sudo apt-get purge -y bluej greenfoot nodered nodejs scratch squeak-vm squeak-plugins-scratch sonic-pi supercollider wolfram-engine
		dialog --msgbox "Raspbian bundled programming software removed!" 9 56
                ;;
        esac
fi
}

###End of Sub-Menus###

###PiPplware Tools Main Menu###
while true; do
	cmd=(dialog --title "$__backtitle" --menu "Choose an option:" 15 76 8)
	options=(
	        1 "Select which device you want to load ROMs from"
		2 "Enable/Disable EmulationStation menus"
	        3 "Set PiPplware aspect ratio (not emulators/games)"
		4 "Disable/Enable Pulseaudio"
		5 "Update RetroPie"
	        6 "Install/Remove Raspbian bundled programming software"
	        )
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	if [[ -n "$choices" ]]; then
	        case $choices in
	        1) change_es_emulators ;;
		2) hide_esmenus ;;
        	3) change_pip_aspect_ratio ;;
		4) disable_pulseaudio ;;
		5) update_retropie ;;
	        6) raspbian_programming ;;
        	esac
	else
		kill_joystick
		break
	fi
done
clear
###End of PiPplware Tools Main Menu###
