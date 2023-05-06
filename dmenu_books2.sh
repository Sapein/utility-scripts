#!/bin/sh

unset IFS

Library_Location="${Library_Location:-${HOME}/library}"

# This is mostly for personal configuration.
dmenu_browseargs="-i -p"
dmenu_curr_args="${dmenu_browseargs}"
dmenu_browseargs_book="${dmenu_browseargs}"
dmenu_browseargs_section="${dmenu_browseargs}"
dmenu_browseargs_shelf="${dmenu_browseargs}"

mix_books="y"
alias extract_path="sed -e 's?^.*\t??'"
alias extract_name="sed -e 's?\t.*??'"
alias get_book_path="sed -e 's?.*\t.*\t??'"
alias get_book_program="sed -e 's?.*\t\(.*\)\t.*?\1?'"
alias get_line="grep -m1"
alias dm='dmenu ${dmenu_curr_args}'

Library_Browse_Shelves() {
    Handle_None() {
        # If the shelf is Not None, we need to adjust the path
        if [ "${Shelf}" != "None" ]
        then
            [ -z "${Shelf}" ] && exit # Unless it's empty
            Current_Path=$(get_line "${Shelf}" "${Current_Path}/shelves" | extract_path)
            echo $Current_Path
        fi
    }

    dmenu_curr_args="${dmenu_browseargs_shelf}"
    [ ! -z "${mix_books}" ] && dmenu_curr_args="${dmenu_curr_args}${dmenu_browseargs_books}"

    while [ -f "${Current_Path}/shelves" ] && [ -z "${Book}" ]
    do
        # IF books exist here, adjust menu.
        if [ -f "${Current_Path}/books" ]
        then
            if [ -z "${mix_books}" ]
            then
                Shelf=$(printf "$(extract_name "${Current_Path}/shelves")\nNone" | dm "What Shelf (Enter None to See Books): ")
                Handle_None
            else
                shelf=$(extract_name "${Current_Path}/shelves")
                books=$(extract_name "${Current_Path}/books")
                input=$(printf "${shelf}\n|\n${books}" | dm "What Book or Shelf: ")
                if echo "${books}" | grep -qw "${input}" > /dev/null
                then
                    Book="${input}"
                elif echo "${shelf}" | grep -qw "${input}" > /dev/null
                then
                    Shelf="${input}"
                fi
                unset books shelf input
            fi
        else
            Shelf=$(extract_name "${Current_Path}/shelves" | dm "What Shelf: ")
            Handle_None
        fi
    done
}

Library_Browse_Books() {
    dmenu_curr_args="${dmenu_browseargs_book}"

    Book=$(extract_name "${Current_Path}/books" | dm "What Book: ")
    [ -z "${Book}" ] && exit
}

Library_Browse_OpenBook() {
    Book_File=$(get_line "${Book}" "${Current_Path}/books" | get_book_path)
    Book_Program=$(get_line "${Book}" "${Current_Path}/books" | get_book_program)

    if printf "${Book_File}" | grep -q ' ' > /dev/null
    then
        "${Book_Program}" "${Book_File}"
    else
        "${Book_Program}" ${Book_File}
    fi
}

Library_Browse(){
    dmenu_curr_args="${dmenu_browseargs_section}"
    Section_Name=$(extract_name "${Library_Location}/catalog" | dm "What Section: ")
    [ -z "${Section_Name}" ] && exit

    Current_Path=$(get_line "${Section_Name}" "${Library_Location}/catalog" | extract_path)
    Section_Path="${Current_Path}"

    Library_Browse_Shelves

    [ -z "${SKIP_BROWSE}" ] && Library_Browse_Books
    Library_Browse_OpenBook
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
    Section_Path=$(grep -m1 "${Section_Name}" "${Library_Location}/catalog" | sed -e 's?.*\t??' | tr -d '\n')
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
    printf "${Shelf_Name}\t${Shelf_Path}\n" >> "${Section_Path}/shelves"
}

Library_BookAdd(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog"| dmenu -i -p "What Section: ")
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep -m1 "${Section_Name}" "${Library_Location}/catalog" | sed -e 's?.*\t??' | tr -d '\n')
    if [ -f "${Section_Path}/shelves" ]
    then
        Shelf=$(sed -e 's?\t.*??' "${Section_Path}/shelves"| dmenu -i -p "What Shelf (Enter None for None): ")
        [ -z "${Shelf}" ] && exit
        if [ "${Shelf}" != "None" ]
        then
            Section_Path=$(grep -m1 "${Shelf}" "${Section_Path}/shelves" | sed -e 's?^.*\t??')
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
        Book_Path=$(printf "${_Files}" | grep -m1 "${Book_Path}" -m1)
        Book_Path="${Section_Path}/$(printf "${Book_Path}" | sed -s 's?'"${Section_Path}"'??')"
        Book_Program=$(printf "" | dmenu -i -p "Enter Reading Program: ")
        [ -z "${Book_Program}" ] && exit
        printf "${Book_Title}\t${Book_Program}\t${Book_Path}\n" >> "${Section_Path}/books"
    fi
}

Library_SectionDelete(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog"| dmenu -i -p "Which Section: ")
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep -m1 "${Section_Name}" "${Library_Location}/catalog" | sed -e 's?.*\t??' | tr -d '\n')
    Section_Line=$(grep -m1 "${Section_Name}" "${Library_Location}/catalog" )

    if [ "$(printf 'No\nYes' | dmenu -i -p "Delete Contents of Section? " | tr -d '\n')" = "Yes" ]
    then
        rmdir --ignore-fail-on-empty "${Section_Path}"
    fi
    sed -s 's?'"${Section_Line}"'??' > "${Library_Location}/catalog"
}

Library_ShelfDelete(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog" | dmenu -i -p "What Section: ")
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep -m1 "${Section_Name}" "${Library_Location}/catalog" | sed -e 's?.*\t??' | tr -d '\n')
    if [ -f "${Section_Path}/shelves" ]
    then
        Shelf=$(sed -e 's?\t.*??' "${Section_Path}/shelves"| dmenu -i -p "Which Shelf: ")
        [ -z "${Shelf}" ] && exit
        Shelf_Path=$(sed -e 's?^.*\t??' "${Section_Path}/shelves")
        Shelf_Line=$(grep -m1 "${Shelf_Path}" "${Section_Path}/shelves")
        if [ "$(printf 'No\nYes' | dmenu -i -p "Delete Contents of Shelf? " | tr -d '\n')" = "Yes" ]
        then
            rmdir --ignore-fail-on-empty "${Shelf_Path}"
        fi
        sed -s 's?'"$(grep -m1 "${Shelf_Line}" "${Section_Path}/shelves")"'??' "${Section_Path}/shelves" > "${Section_Path}/shelves.tmp" &&
            mv "${Section_Path}/shelves.tmp" "${Section_Path}/shelves"
    fi
}

Library_BookRemove(){
    Section_Name=$(sed -e 's?\t.*??' "${Library_Location}/catalog"| dmenu -i -p "What Section: ")
    [ -z "${Section_Name}" ] && exit
    Section_Path=$(grep -m1 "${Section_Name}" "${Library_Location}/catalog" | sed -e 's?.*\t??')

    if [ -f "${Section_Path}/shelves" ]
    then
        Shelf=$(sed -e 's?\t.*??' "${Section_Path}/shelves"| dmenu -i -p "What Shelf (Enter None for No Shelf): ")
        if [ "${Shelf}" != "_None_" ]
        then
            [ -z "${Shelf}" ] && exit
            Section_Path=$(grep -m1 "${Shelf}" "${Section_Path}/shelves" | sed -e 's?^.*\t??')
        fi
    fi

    Book=$(sed -e 's?\t.*??' "${Section_Path}/books"| dmenu -i -p "What Book: ")
    [ -z "${Book}" ] && exit
    Book_File=$(grep -m1 "${Book}" "${Section_Path}/books" | sed -e 's?.*\t.*\t??')
    Book_Line=$(grep -m1 "${Book}" "${Section_Path}/books")
    if [ "$(printf 'No\nYes' | dmenu -i -p "Delete Book on Disk: " | tr -d '\n')" = "Yes" ]
    then
        rm "${Book_File}"
    fi
    sed -s 's?'"$(grep -m1 "${Book_Line}" "${Section_Path}/books")"'??' "${Section_Path}/books" > "${Section_Path}/books.tmp" &&
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
        case "$(printf "${ManageOptions}" | dm 'What do you wish to do? ')" in
            "Section Create"*)
                Library_SectionCreate
                ;;
            "Section Delete"*)
                Library_SectionDelete
                ;;
            "Shelf Create"*)
                [ "$(echo "N\ny" | dm '!! WARNING !! This does not support nested shelves! To continue please select "y": ')" = "y"] && Library_ShelfCreate
                ;;
            "Shelf Delete"*)
                [ "$(echo "N\ny" | dm '!! WARNING !! This does not support nested shelves! To continue please select "y": ')" = "y"] && Library_ShelfDelete
                ;;
            "Book Add"*)
                [ "$(echo "N\ny" | dm '!! WARNING !! This does not support nested shelves! To continue please select "y": ')" = "y"] && Library_BookAdd
                ;;
            "Book Remove"*)
                [ "$(echo "N\ny" | dm '!! WARNING !! This does not support nested shelves! To continue please select "y": ')" = "y"] && Library_BookRemove
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
