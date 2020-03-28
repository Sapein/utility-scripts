#!/bin/sh

unset IFS

_G_KNOWN_METHODS="xdotool:i3"

detect_available_methods(){
    # detect_available_methods
    # Returns the available methods of effecting windows.
    # args: None
    # returns: Available Methods (List, Colon-Separated) 
    # return var: G_AVAILABLE_METHODS
    xdotool > /dev/null 2>&1
    if [ $? -ne 127 ]
    then
        G_AVAILABLE_METHODS="${G_AVAILABLE_METHODS}xdotool:"
    fi

    if i3 -v > /dev/null 2>&1
    then
        G_AVAILABLE_METHODS="${G_AVAILABLE_METHODS}i3:"
    fi
    G_AVAILABLE_MEHTHODS=$(echo "${G_AVAILABLE_MEHTHODS}" | sed -e 's?:$??')
}

get_method(){
    # get_section_name
    # Returns the Name/Title of a Section
    # args: Section
    # returns: Section Name
    # return var: G_SECTION_NAME, $? (0 = No Error, 1 = Error)
}

xdotool_method(){
    : 
}

i3_method(){
    :
}
