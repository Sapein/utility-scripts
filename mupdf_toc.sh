#!/bin/sh

unset IFS

get_section_name(){
    # get_section_name
    # Returns the Name/Title of a Section
    # args: Section
    # returns: Section Name
    # return var: G_SECTION_NAME, $? (0 = No Error, 1 = Error)

    section="${1}"
    section_name=$(echo "${section:?You must pass in section!}" | grep $[\|\+] -m1 | sed -e 's?.*"\(.*\)".*?\1?')
    if [ -z "${section}" ]
    then
        unset section
        unset section_name
        return -1
    else
        G_SECTION_NAME=${section_name}
        unset section
        unset section_Name
        return 0
    fi
}

section_has_children()(
    # section_has_children
    # Returns whether or not the section has children.
    # args: Section
    # returns: Has Children (0 = False/None, 1=True, 2=Error)
    # return var: $?

    unset IFS
    section="${1}"
    first_char=$(echo "${section:?You must pass in section!}" | grep $[\|\+] -m1 | sed -e 's?\(\|\+\)?\1\t.*?\1?')
    if [ "${first_char}" = "|" ]
    then
        return 0
    elif [ "${first_char}" = "+" ]
    then
        return 1
    else
        return 2
    fi
)

section_child_count()(
    # section_child_count
    # Returns the amount of direct and indirect children
    # args: Section (1), Section (2)
    # returns: Child Integer (-1 = Error, 0+ = Valid Values)
    # return var: $?

    section="${1}"
    sections="${2}"
    if section_has_children "${section}"
    then
        section=$(echo "${section:?You must pass in section!}" | grep $[\|\+] -m1)
        sections=$(echo "${sections:?You must pass in the other sections!}" | sed -e '/'"${section}"'/d')
        tab_count=$(echo "${section}" | sed -e 's?^.\(\t*\).*?\1?' | tr -d '\n' | wc -m)
        children=0
        IFS='
'
        for _section in ${sections}
        do
            _tab_count=$(echo "${_section}" | sed -e 's?^.\(\t*\).*?\1?' | tr -d '\n' | wc -m)
            if [ "${tab_count}" -gt "${_tab_count}" ]
            then
                children=$(($children + 1))
            else
                break
            fi
        done
        return children
    fi
    return -1
)

section_direct_child_count()(
    # section_direct_child_count
    # Returns the amount of children that are directly under the parent,
    # excluding sub-children.
    # args: Section (1), Section (2)
    # returns: Child Integer (-1 = Error, 0+ = Valid Values)
    # return var: $?

    unset IFS
    section="${1}"
    sections="${2}"
    if section_has_children "${section}"
    then
        section=$(echo "${section:?You must pass in section!}" | grep $[\|\+] -m1)
        sections=$(echo "${sections:?You must pass in the other sections!}" | sed -e '/'"${section}"'/d')
        tab_count=$(echo "${section}" | sed -e 's?^.\(\t*\).*?\1?' | tr -d '\n' | wc -m)
        children=0
        IFS='
'
        for _section in ${sections}
        do
            _tab_count=$(echo "${_section}" | sed -e 's?^.\(\t*\).*?\1?' | tr -d '\n' | wc -m)
            if [ $((tab_count + 1)) -eq "${_tab_count}" ]
            then
                children=$(($children + 1))
            then
                break
            fi
        done
        return children
    fi
    return -1
)

get_section_children(){
    # get_section_children
    # Returns all children of the first section, direct and indirect.
    # args: Section (1), Section (2)
    # returns: Child Sections
    # return var: G_SECTION_CHILDREN

    section="${1}"
    sections="${2}"
    if section_has_children "${section}"
    then
        section=$(echo "${section:?You must pass in section!}" | grep $[\|\+] -m1)
        sections=$(echo "${sections:?You must pass in the other sections!}" | sed -e '/'"${section}"'/d')
        children
        tab_count=$(echo "${section}" | sed -e 's?^.\(\t*\).*?\1?' | tr -d '\n' | wc -m)
        IFS='
'
        for _section in ${sections}
        do
            _tab_count=$(echo "${_section}" | sed -e 's?^.\(\t*\).*?\1?' | tr -d '\n' | wc -m)
            if [ "${tab_count}" -gt "${_tab_count}" ]
            then
                children_sections="${children_sections}${_section}\n"
            else
                break
            fi
        done
        unset IFS
        G_SECTION_CHILDREN=children_sections
        unset section
        unset sections
        unset children_sections
    fi
}

get_section_direct_children(){
    # get_section_direct_children
    # Returns all direct children of the first section.
    # args: Section (1), Section (2)
    # returns: Child Sections
    # return var: G_SECTION_CHILDREN

    section="${1}"
    sections="${2}"
    if section_has_children "${section}"
    then
        section=$(echo "${section:?You must pass in section!}" | grep $[\|\+] -m1)
        sections=$(echo "${sections:?You must pass in the other sections!}" | sed -e '/'"${section}"'/d')
        children
        tab_count=$(echo "${section}" | sed -e 's?^.\(\t*\).*?\1?' | tr -d '\n' | wc -m)
        IFS='
'
        for _section in ${sections}
        do
            _tab_count=$(echo "${_section}" | sed -e 's?^.\(\t*\).*?\1?' | tr -d '\n' | wc -m)
            if [ $(("${tab_count}" + 1)) -eq "${_tab_count}" ]
            then
                children_sections="${children_sections}${_section}\n"
            else
                break
            fi
        done
        unset IFS
        G_SECTION_CHILDREN=children_sections
        unset section
        unset sections
        unset children_sections
    fi
}

get_section_page()(
    # get_section_page
    # args: Section
    # returns: Page Number (-1 = Error)
    # return var: $?

    section="${1}"
    section_page=$(echo "${section:?You must pass in section!}" | grep $[\|\+] -m1 | sed -e 's?.*#\([0-9]*\).*?\1?')
    if [ -z "${section}" ]
    then
        return -1
    else
        return $section_page
    fi
)
