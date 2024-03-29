# Utility Scripts
  A collection of scripts and the like that help manage my system in some ways or provide other utilities.

## License and Copyright
  All software in this repository is licensed under the MIT License, for more information see the LICENSE file

  All copyright belongs to the individual owners and authors
## Scripts
- Touchpad_Toggle
- dmenu_books
- bbs_menu

### Touchpad_Toggle
  This simply toggles the touchpad, it also provides functions that allow you to setup your own stuff.

### dmenu_books
   This is a script that allows you to open up books and documentation from dmenu.
Everything is stored under ~/library for the most part. Run it with no arguments for the Librarian,
otherwise pass it in either "Browse", "Manage", "Librarian", "BookAdd", "BookRemove", "ShelfDelete", 
"ShelfCreate", "SectionCreate", or "SectionDelete" for the related functionality.

The format for all storage have the fields delimitated by tabs and are as follows:
Name    Path

For books it uses the following format, also delimitated by tabs:
Name    Reader    Path

### dmenu_books2
   This is an updated version of `dmenu_books`. The main change is that browsing now supports nested
shelves and also shelves and books can be displayed next to each other, along with some minor code cleanup.

Unfortunately, this breaks the `Shelf Delete`, `Shelf Create`, `Book Add`, and `Book Delete` functionality.
This will be restored in the future.

The format for all storage have the fields delimitated by tabs and are as follows:
Name    Path

For books it uses the following format, also delimitated by tabs:
Name    Reader    Path


### dmenu_flatpak  
   This is a very simple flatpak launcher for dmenu. It doesn't do anything special or does any special filtering.
This only displays things that have the `current` option.

### bbs_menu  
   This is a script that allows you to store a list of BBS systems to connect to from dmenu.
Everything is under ~/.config/bbs_list for the most part. It is forked from dmenu_books as well.

The format for bbs_list has the fields delimitated by tabs with each entry being separated by a new line.
The each line is organized as follows:
Name    Program    BBS Host
