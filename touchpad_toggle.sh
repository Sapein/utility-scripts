#!/bin/sh

get_touchpad_status() {
    # get_touchpad_status
    # args: Touchpad ID
    # returns: Status Integer (0 = Disabled, 1 = Enabled, 10 = Error)
    # return var: $?
    touchpad="${1}"
    correct_line=$(xinput list-props "${touchpad}" 2> /dev/null | grep "Device Enabled")
    status=$(echo "${correct_line}" | cut -d" " -f3 | cut -d":" -f2)
    if [ "${status}" -eq "0" ] || [ "${status}" -eq "1" ]
    then
        return "${status}"
    else
        return 10;
    fi
}

find_touchpad() {
    # find_touchpad
    # args: None
    # returns: Integer of first touchpad
    # return var: $?
    touchpad_line=$(xinput | grep "Touchpad")
    touchpad_id=$(echo "${touchpad_line}" | cut -d"=" -f2 | cut -d"[" -f1)
    return "${touchpad_id}"
}


translate_status() {
    # translate_status
    # args: Touchpad Status
    # returns: Status Text
    # return var: G_TOUCHPAD_STATUS
    touchpad_status="${1}"
    if [ "${touchpad_status}" = "0" ]
    then
        G_TOUCHPAD_STATUS="disable"
    elif [ "${touchpad_status}" = "1" ]
    then
        G_TOUCHPAD_STATUS="enable"
    else
        G_TOUCHPAD_STATUS="UNKNOWN"
    fi
}

inverse_status() {
    # inverse_status
    # args: Touchpad Status (int)
    # returns: Touchpad Status Inverse (int) (or Touchpad Status if unknown)
    # return var: $?
    touchpad_status="${1}"
    if [ "${touchpad_status}" = "0" ]
    then
        return 1
    elif [ "${touchpad_status}" = "1" ]
    then
        return 0
    else
        return "${touchpad_status}"
    fi
}

switch_touchpad() {
    # switch_touchpad
    # args: Touchpad ID (1), Touchpad Switch (2)
    # returns None
    # return var: None
    touchpad_id="${1}"
    touchpad_switch="${2}"
    xinput "${touchpad_switch}" "${touchpad_id}"
}

find_touchpad
get_touchpad_status "${?}"
inverse_status "${?}"
translate_status "${?}"
find_touchpad
switch_touchpad "${?}" "${G_TOUCHPAD_STATUS}"
