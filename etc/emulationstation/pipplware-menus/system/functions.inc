#!/bin/bash

enable_joystick() {
    local params=("$@")
    if [[ "${#params[@]}" -eq 0 ]]; then
        params=(kcub1 kcuf1 kcuu1 kcud1 0x0a 0x20)
    fi
    # get the first joystick device (if not already set)
    [[ -c "$__joy2key_dev" ]] || __joy2key_dev="/dev/input/jsX"
    # if no joystick device, or joy2key is already running exit
    [[ -z "$__joy2key_dev" ]] || pgrep -f joy2key.py >/dev/null && return 1
    # if joy2key.py is installed run it with cursor keys for axis, and enter + space for buttons 0 and 1
    if "/home/pi/RetroPie-Setup/scriptmodules/supplementary/runcommand/joy2key.py" "$__joy2key_dev" "${params[@]}" & 2>/dev/null; then
        __joy2key_pid=$!
        return 0
    fi
    return 1
}

kill_joystick() {
if [[ -n $__joy2key_pid ]]; then
    kill -INT $__joy2key_pid 2>/dev/null
    sleep 1
fi
}

selectDrive() {
    local usb_only=0
    local text=$(sudo lsblk --output KNAME,LABEL,TYPE,MOUNTPOINT,TRAN -p -P | grep -v -E "MOUNTPOINT=\".*/boot\"")
    if [ $1 ]; then
        usb_only=1
        declare -A usb_disks
        
        local SAVEDIFS=$IFS
        local IFS=$'\n'
        for l in $text
        do
            [[ -z $(echo $l | grep -E "TRAN=\"usb\"") ]] && continue
            local DEV=$(echo $l | sed -n 's/.*KNAME="\([^"]*\)".*/\1/p')
            usb_disks+=(["$DEV"]="$DEV")
        done
        IFS=$SAVEDIFS
    fi

    local current_mp=$(stat --printf "%m" .)
    local home_mp=$(stat --printf "%m" ~)

    declare -A drives
    
    local SAVEDIFS=$IFS
    local IFS=$'\n'
    for l in $text
    do
        # We are only interested in partitions
        [[ -z $(echo $l | grep -E "TYPE=\"part\"") ]] && continue

        local DEV=$(echo $l | sed -n 's/.*KNAME="\([^"]*\)".*/\1/p')

        local LABEL=$(echo $l | sed -n 's/.*LABEL="\([^"]*\)".*/\1/p')
        local MOUNTPOINT=$(echo $l | sed -n 's/.*MOUNTPOINT="\([^"]*\)".*/\1/p')
        
        # Only if mountpoint exist
        [[ -z $MOUNTPOINT ]] && continue
        
        # If usb only check if this partition belongs to a usb device.
        if [[ "$usb_only" == "1" ]]; then
          [[ ${#usb_disks[@]} -eq 0 ]] && break
          local continue_outer=0
          for u in ${!usb_disks[@]}
          do
              if [[ -z $(echo $DEV | grep -E "$u") ]]; then
                continue_outer=1
              else
                continue_outer=0
		break
              fi
          done
          [[ $continue_outer -eq 1 ]] && continue
        fi

        local VOL="$DEV"
        if [ -n "$LABEL" ]; then
            VOL+=" ($LABEL)"
        fi
        if [ $MOUNTPOINT == $current_mp ]; then
            VOL+=" *"
        fi
        if [ $MOUNTPOINT == $home_mp ]; then
            MOUNTPOINT=`echo ~`
        fi
        drives+=(["$MOUNTPOINT"]="$VOL")
    done
    IFS=$SAVEDIFS

    local MENU_OPTIONS=()
    local COUNT=0

    for d in "${!drives[@]}"; do
        COUNT=$[COUNT+1]
        local STATE="OFF"
        [ $COUNT == 1 ] && STATE="ON"
        MENU_OPTIONS+=("${d}" "${drives[$d]}")
    done

    [ "$COUNT" -eq "0" ] && return 0  
    
    DRIVE=$(dialog --menu "Select drive:" 16 76 $COUNT "${MENU_OPTIONS[@]}" 3>&1 1>&2 2>&3)
    echo $DRIVE

}

backup() {
dpkg-query -f '${binary:Package}=${Version} ' -W > ~/installed_packages.txt
sudo tar cpzvf "$1"/PI_BACKUP.tar.gz --exclude='PI_BACKUP.tar.gz' ~ /etc /opt/retropie/configs /boot/config.txt /boot/cmdline.txt
if [ $? -eq 0 ]; then
    dialog --title "Backup Settings" --msgbox "BACKUP $1/PI_BACKUP.tar.gz COMPLETE!" 12 56
else
    sudo rm "$1"/PI_BACKUP.tar.gz &>/dev/null
    dialog --title "Backup Settings" --msgbox "INSUFFICIENT DISK SPACE!\n\nPlease free some space and try again." 12 56
fi
rm ~/installed_packages.txt &> /dev/null
}

restore() {
if [ ! -f "$1/PI_BACKUP.tar.gz" ]; then
    dialog --title "Restore Settings" --msgbox "No BACKUP found!\n\nPlease create a backup first, or choose a device with a Backup." 12 56
else
    sudo tar zxpvf "$1"/PI_BACKUP.tar.gz --wildcards --no-anchored -C / '*installed_packages.txt*' '*etc/apt/*'
    if [ $? -eq 0 ]; then
        if [ -f "$HOME/installed_packages.txt" ]; then
	    sudo apt-get update && sudo apt-get install -y $(cat ~/installed_packages.txt)
        fi
	sudo tar zxpvf "$1"/PI_BACKUP.tar.gz -C /
    fi
    if [ $? -eq 0 ]; then
        rm "$HOME"/installed_packages.txt &> /dev/null
        dialog --title "Restore Settings" --msgbox "RESTORE COMPLETE!" 12 56
    else
        dialog --title "Restore Settings" --msgbox "INSUFFICIENT DISK SPACE!\n\nPlease free some space and try again." 12 56
    fi
fi
}

export_roms() {
mkdir -p "$1"/RetroPie/configs &>/dev/null
cp -uv --preserve=timestamps /opt/retropie/emulators/gpsp/raspberrypi/gba_bios.bin "$1"/RetroPie/BIOS/gba_bios.bin &>/dev/null
mkdir -p "$1"/RetroPie/emulators/gpsp/raspberrypi &>/dev/null
cp -uv --preserve=timestamps /opt/retropie/emulators/gpsp/raspberrypi/*.s* "$1"/RetroPie/emulators/gpsp/raspberrypi &>/dev/null
cp -uv --preserve=timestamps /opt/retropie/emulators/gpsp/raspberrypi/*.cfg "$1"/RetroPie/emulators/gpsp/raspberrypi &>/dev/null
mkdir -p "$1"/RetroPie/emulators/pifba/saves &>/dev/null
cp -uv --preserve=timestamps /opt/retropie/emulators/pifba/saves/* "$1"/RetroPie/emulators/pifba/saves &>/dev/null
cp -uv --preserve=timestamps /opt/retropie/emulators/pifba/*.cfg "$1"/RetroPie/emulators/pifba/ &>/dev/null
mkdir -p "$1"/RetroPie/emulators/mame4all-pi/hi &>/dev/null
mkdir -p "$1"/RetroPie/emulators/mame4all-pi/sta &>/dev/null
cp -uv --preserve=timestamps /opt/retropie/emulators/mame4all-pi/hi/* "$1"/RetroPie/emulators/mame4all-pi/hi &>/dev/null
cp -uv --preserve=timestamps /opt/retropie/emulators/mame4all-pi/sta/* "$1"/RetroPie/emulators/mame4all-pi/sta &>/dev/null
cp -uv --preserve=timestamps /opt/retropie/emulators/mame4all-pi/mame.cfg "$1"/RetroPie/emulators/mame4all-pi/mame.cfg &>/dev/null
rsync -ruv --times /opt/retropie/configs/ "$1"/RetroPie/configs
rsync -ruv --times ~/RetroPie/ "$1"/RetroPie
if [ $? -eq 0 ]; then
    dialog --title "Export ROMs to USB" --msgbox "ROMS EXPORTED TO $1 !\n\nTo load ROMs directly from this device, please go to Emulation Station Tools and select the apropriate option." 12 56 >/dev/tty
else
    dialog --title "Export ROMs to USB" --msgbox "INSUFFICIENT DISK SPACE IN $1 !\n\nPlease free some space in $1 and try again." 12 56 >/dev/tty
fi
}

import_roms() {
sudo cp -uv --preserve=timestamps "$1"/RetroPie/roms/emulators/gpsp/raspberrypi/* ~/RetroPie/emulators/gpsp/raspberrypi &>/dev/null
sudo cp -uv --preserve=timestamps "$1"/RetroPie/BIOS/gba_bios.bin /opt/retropie/emulators/gpsp/raspberrypi/gba_bios.bin &>/dev/null
cp -uv --preserve=timestamps "$1"/RetroPie/BIOS/neogeo.zip ~/RetroPie/roms/mame/ &>/dev/null
cp -uv --preserve=timestamps "$1"/RetroPie/BIOS/neogeo.zip ~/RetroPie/roms/fba/ &>/dev/null
cp -uv --preserve=timestamps "$1"/RetroPie/BIOS/neogeo.zip ~/RetroPie/roms/neogeo/ &>/dev/null
sudo cp -uv --preserve=timestamps "$1"/RetroPie/emulators/pifba/* /opt/retropie/emulators/pifba &>/dev/null
sudo cp -uv --preserve=timestamps "$1"/RetroPie/emulators/pifba/saves/* /opt/retropie/emulators/pifba/saves &>/dev/null
sudo cp -uv --preserve=timestamps "$1"/RetroPie/emulators/mame4all-pi/* /opt/retropie/emulators/mame4all-pi/ &>/dev/null
sudo cp -uv --preserve=timestamps "$1"/RetroPie/emulators/mame4all-pi/hi/* /opt/retropie/emulators/mame4all-pi/hi &>/dev/null
sudo cp -uv --preserve=timestamps "$1"/RetroPie/emulators/mame4all-pi/sta/* /opt/retropie/emulators/mame4all-pi/sta &>/dev/null
rsync -ruv --times --exclude=emulators --exclude=configs --exclude=.emulationstation "$1"/RetroPie/ ~/RetroPie
rsync -ruv --times "$1"/RetroPie/configs/ /opt/retropie/configs
if [ $? -eq 0 ]; then
    dialog --title "Import ROMs to SD Card" --msgbox "ROMS IMPORTED TO SD CARD!\n\nTo load ROMs from the SD Card (original behaviour), please go to Emulation Station Tools and select the apropriate option." 12 56 >/dev/tty
else
    dialog --title "Import ROMs to SD Card" --msgbox "No ROMs found in the USB device $1/RetroPie/ !\n\nPlease run Export ROMs to USB first, copy your ROMs to the apropriate folders and try again." 12 56 >/dev/tty
fi
}
