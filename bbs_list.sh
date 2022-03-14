#!/bin/sh

unset IFS

BBS_Directory_Path="${BBS_Directory_Path:-${HOME}/.config/bbs-directory}"

# This is mostly for personal configuration.
dmenu_browseargs="-i -p"
dmenu_browseargs_book="${dmenu_browseargs}"
dmenu_browseargs_section="${dmenu_browseargs}"
dmenu_browseargs_shelf="${dmenu_browseargs}"

Directory_Browse(){
    BBS=$(sed -e 's?\t.*??' "${BBS_Directory_Path}" | dmenu ${dmenu_browseargs_book} "What BBS: ")
    [ -z "${BBS}" ] && exit
    BBS_Host=$(grep -m1 "${BBS}" "${BBS_Directory_Path}" | sed -e 's?.*\t.*\t??')
    BBS_Program=$(grep -m1 "${BBS}" "${BBS_Directory_Path}" | sed -e 's?.*\t\(.*\)\t.*?\1?')
    if printf "${BBS_Host}" | grep ' ' > /dev/null
    then
        echo ${BBS_Program} ${BBS_Host}
        ${BBS_Program} "${BBS_Host}"
    else
        echo ${BBS_Program} ${BBS_Host}
        ${BBS_Program} "${BBS_Host}"
    fi
}

Directory_Add(){
    BBS_Name=$(printf '' | dmenu -i -p "BBS Name: ")
    [ -z "${BBS_Name}" ] && exit
    BBS_Host=$(printf '' | dmenu -p "BBS Hostname: " | tr -d '\n') 
    [ -z "${BBS_Host}" ] && exit
    BBS_Program=$(printf "" | dmenu -i -p "Enter Connection Program: ")
    [ -z "${BBS_Program}" ] && exit
    printf "${BBS_Name}\t${BBS_Program}\t${BBS_Host}\n" >> "${BBS_Directory_Path}"
}

Directory_Remove(){
    BBS=$(sed -e 's?\t.*??' "${BBS_Directory_Path}"| dmenu -i -p "What Book: ")
    [ -z "${BBS}" ] && exit
    BBS_Host=$(grep -m1 "${BBS}" "${BBS_Directory_Path}" | sed -e 's?.*\t.*\t??')
    BBS_Line=$(grep -m1 "${BBS}" "${BBS_Directory_Path}")
    sed -s 's?'"$(grep -m1 "${BBS_Line}" "${BBS_Directory_Path}")"'??' "${BBS_Directory_Path}" > "${BBS_Directory_Path}.tmp" &&
        mv "${BBS_Directory_Path}.tmp" "${BBS_Directory_Path}"
}

Directorian() {
    Options="Manage\nBrowse\n"
    case "$(printf "${Options}" | dmenu -i -p 'What do you wish to do? ')" in
        Manage*)
            Directory_Manage
            ;;
        Browse*)
            Directory_Browse
            ;;
    esac
}

Directory_Manage() {
    ManageOptions="BBS Add\nBBS Remove"
    case "$(printf "${ManageOptions}" | dmenu -i -p 'What do you wish to do? ')" in
        "BBS Add"*)
            Directory_Add
            ;;
        "BBS Remove"*)
            Directory_Remove
            ;;
    esac
}

if [ -z "${1}" ]
then
    Directorian
else
    if [ "${1}" = "Directorian" ] || [ "${1}" = "directorian" ] || [ "${1}" = "menu" ]
    then
        Directorian
    else
        Directory_"${1}"
    fi
fi
