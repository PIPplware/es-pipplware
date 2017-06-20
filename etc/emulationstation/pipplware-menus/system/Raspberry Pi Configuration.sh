#!/bin/bash
source /etc/emulationstation/pipplware-menus/system/functions.inc

###Joystick Support###
enable_joystick

sudo raspi-config

kill_joystick
clear
