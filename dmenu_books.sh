#!/bin/sh

unset IFS

Library_Location="${Library_Location:-${HOME}/library}"

# This is mostly for personal configuration.
dmenu_browseargs="-i -p"
dmenu_browseargs_book="-b ${dmenu_browseargs}"
dmenu_browseargs_section="${dmenu_browseargs}"
dmenu_browseargs_shelf="${dmenu_browseargs}"

Library_Browse(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog" | dmenu ${dmenu_browseargs_section} "What Section: ") 
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep "${Section_Name}" "${Library_Location}/catalog" | sed -e 's?.*\t??')
    if [ -f "${Section_Path}/shelves" ]
    then
        Shelf=$(sed -e 's?\t.*??' "${Section_Path}/shelves" | dmenu ${dmenu_browseargs_shelf} "What Shelf (Enter None for None): ")
        if [ "${Shelf}" != "None" ]
        then
            [ -z "${Shelf}" ] && exit
            Section_Path=$(grep "${Shelf}" "${Section_Path}/shelves" | sed -e 's?^.*\t??')
        fi
    fi
    Book=$(sed -e 's?\t.*??' "${Section_Path}/books" | dmenu ${dmenu_browseargs_book} "What Book: ")
    [ -z "${Book}" ] && exit
    Book_File=$(grep "${Book}" "${Section_Path}/books" | sed -e 's?.*\t.*\t??')
    Book_Program=$(grep "${Book}" "${Section_Path}/books" | sed -e 's?.*\t\(.*\)\t.*?\1?')
    "${Book_Program}" "${Book_File}"
}

Library_SectionCreate(){
    Section_Name=$(printf '' | dmenu -p "Section Name: " | tr -d '\n')
    [ -z "${Section_Name}" ] && exit
    Section_NamePathified=$(printf "${Section_Name}" | sed -e 's? ?_?' | tr -d '\n')
    if [ "$(printf 'Yes\nNo' | dmenu -i -p "Link to a Directory? " | tr -d '\n')" = "Yes" ]
    then
        Section_Path=$(printf '' | dmenu -p "Section Path: " | tr -d '\n') 
        [ -z "${Section_Path}" ] && exit
    else
        Section_Path="${Library_Location}/${Section_NamePathified}"
        mkdir "${Section_Path}"
    fi
    printf "${Section_Name}\t${Section_Path}\n" >> "${Library_Location}/catalog"
}

Library_ShelfCreate(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog"| dmenu -i -p "What Section: ") 
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep "${Section_Name}" "${Library_Location}/catalog"  | sed -e 's?.*\t??' | tr -d '\n')
    Shelf_Name=$(printf "" | dmenu -i -p "Shelf Name: ")
    [ -z "${Shelf_Name}" ] && exit
    if [ "$(printf 'Yes\nNo' | dmenu -i -p "Link to a Directory? " | tr -d '\n')" = "Yes" ]
    then
        Shelf_Path=$(printf '' | dmenu -p "Shelf Path: " | tr -d '\n') 
        [ -z "$Shelf_Path" ] && exit
    else
        Shelf_Path=$(echo "${Shelf_Name}" | sed -e 's? ?_?' | tr -d '\n')
        Shelf_Path="${Section_Path}/${Shelf_Path}"
        mkdir "${Shelf_Path}"
    fi
    printf "${Shelf_Name}\t${Section_Path}/${Shelf_Path}\n" >> "${Section_Path}/shelves"
}

Library_BookAdd(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog"| dmenu -i -p "What Section: ") 
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep "${Section_Name}" "${Library_Location}/catalog"  | sed -e 's?.*\t??' | tr -d '\n')
    if [ -f "${Section_Path}/shelves" ]
    then
        Shelf=$(sed -e 's?\t.*??' "${Section_Path}/shelves"| dmenu -i -p "What Shelf (Enter None for None): ")
        [ -z "${Shelf}" ] && exit
        if [ "${Shelf}" != "None" ]
        then
            Section_Path=$(grep "${Shelf}" "${Section_Path}/shelves" | sed -e 's?^.*\t??')
        fi
    fi
    Book_Title=$(printf '' | dmenu -i -p "Book Title: ")
    [ -z "${Book_Title}" ] && exit
    if [ "$(printf 'No\nYes' | dmenu -i -p "Manually Input Path? " | tr -d '\n')" = "Yes" ]
    then
        Book_Path=$(printf '' | dmenu -p "File Path: " | tr -d '\n') 
        [ -z "${Book_Path}" ] && exit
    else
        Files=""
        _Files=""
        for file in ${Section_Path}/*
        do
            Files="${Files}"$(basename "${file}")
            Files="${Files}\n"
            _Files="${Files}${file}"
        done
        Book_Path=$(printf "${Files}" | dmenu -i -p "Choose Book File: ")
        [ -z "${Book_Path}" ] && exit
        Book_Path=$(printf "${_Files}" | grep "${Book_Path}")
        Book_Path="${Section_Path}/$(printf "${Book_Path}" | sed -s 's?'"${Section_Path}"'??')"
        Book_Program=$(printf "" | dmenu -i -p "Enter Reading Program: ")
        [ -z "${Book_Program}" ] && exit
        printf "${Book_Title}\t${Book_Program}\t${Book_Path}\n" >> "${Section_Path}/books"
    fi
}

Library_SectionDelete(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog"| dmenu -i -p "Which Section: ") 
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep "${Section_Name}" "${Library_Location}/catalog"  | sed -e 's?.*\t??' | tr -d '\n')
    Section_Line=$(grep "${Section_Name}" "${Library_Location}/catalog")

    if [ "$(printf 'No\nYes' | dmenu -i -p "Delete Contents of Section? " | tr -d '\n')" = "Yes" ]
    then
        rmdir --ignore-fail-on-empty "${Section_Path}"
    fi
    sed -s 's?'"${Section_Line}"'??' > "${Library_Location}/catalog"
}

Library_ShelfDelete(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog" | dmenu -i -p "What Section: ") 
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep "${Section_Name}" "${Library_Location}/catalog"  | sed -e 's?.*\t??' | tr -d '\n')
    if [ -f "${Section_Path}/shelves" ]
    then
        Shelf=$(sed -e 's?\t.*??' "${Section_Path}/shelves"| dmenu -i -p "Which Shelf: ")
        [ -z "${Shelf}" ] && exit
        Shelf_Path=$(sed -e 's?^.*\t??' "${Section_Path}/shelves")
        Shelf_Line=$(grep "${Shelf_Path}" "${Section_Path}/shelves") 
        if [ "$(printf 'No\nYes' | dmenu -i -p "Delete Contents of Shelf? " | tr -d '\n')" = "Yes" ]
        then
            rmdir --ignore-fail-on-empty "${Shelf_Path}"
        fi
        sed -s 's?'"$(grep "${Shelf_Line}" "${Section_Path}/shelves")"'??' "${Section_Path}/shelves" > "${Section_Path}/shelves.tmp" &&
            mv "${Section_Path}/shelves.tmp" "${Section_Path}/shelves"
    fi
}

Library_BookRemove(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog"| dmenu -i -p "What Section: ") 
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep "${Section_Name}" "${Library_Location}/catalog" | sed -e 's?.*\t??')

    if [ -f "${Section_Path}/shelves" ]
    then
        Shelf=$(sed -e 's?\t.*??' "${Section_Path}/shelves"| dmenu -i -p "What Shelf (Enter None for No Shelf): ")
        if [ "${Shelf}" != "_None_" ]
        then
            [ -z "${Shelf}" ] && exit
            Section_Path=$(grep "${Shelf}" "${Section_Path}/shelves" | sed -e 's?^.*\t??')
        fi
    fi

    Book=$(sed -e 's?\t.*??' "${Section_Path}/books"| dmenu -i -p "What Book: ")
    [ -z "${Book}" ] && exit
    Book_File=$(grep "${Book}" "${Section_Path}/books" | sed -e 's?.*\t.*\t??')
    Book_Line=$(grep "${Book}" "${Section_Path}/books")
    if [ "$(printf 'No\nYes' | dmenu -i -p "Delete Book on Disk: " | tr -d '\n')" = "Yes" ]
    then
        rm "${Book_File}"
    fi
    sed -s 's?'"$(grep "${Book_Line}" "${Section_Path}/books")"'??' "${Section_Path}/books" > "${Section_Path}/books.tmp" &&
        mv "${Section_Path}/books.tmp" "${Section_Path}/books"
}

Librarian() {
    Options="Manage\nBrowse\n"
    case "$(printf "${Options}" | dmenu -i -p 'What do you wish to do? ')" in
        Manage*)
            Library_Manage
            ;;
        Browse*)
            Library_Browse
            ;;
    esac
}

Library_Manage(){
    ManageOptions="Section Create\nSection Delete\nShelf Create\nShelf Delete\nBook Add\nBook Remove"
    case "$(printf "${ManageOptions}" | dmenu -i -p 'What do you wish to do? ')" in
        "Section Create"*)
            Library_SectionCreate
            ;;
        "Section Delete"*)
            Library_SectionDelete
            ;;
        "Shelf Create"*)
            Library_ShelfCreate
            ;;
        "Shelf Delete"*)
            Library_ShelfDelete
            ;;
        "Book Add"*)
            Library_BookAdd
            ;;
        "Book Remove"*)
            Library_BookRemove
            ;;
    esac
}

if [ -z "${1}" ]
then
    Librarian
else
    if [ "${1}" = "Librarian" ] || [ "${1}" = "librarian" ] || [ "${1}" = "menu" ]
    then
        Librarian
    else
        Library_"${1}"
    fi
fi
