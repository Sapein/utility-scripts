#!/bin/sh

NAME_SCRIPT='NF == 4{print $1" "$2}
NF == 3 {print $1}'

PROGRAM_SCRIPT='NF == 2 {print $2}
NF == 3 {print $3}'

dmenu_browseargs="-i -p"
result=$(flatpak list --columns="name,version,options" | grep ",current" | awk "${NAME_SCRIPT}" | sed -s 's?Name??' | sed -s 's? $??' | dmenu ${dmenu_browseargs} "What Flatpak: ")
flatpak run $(flatpak list --columns="name,app" | grep "${result}" | awk -s "${PROGRAM_SCRIPT}" )
