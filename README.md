# System Scripts
  A collection of scripts and the like that help manage my system in some ways.

## License and Copyright
  All software in this repository is licensed under the MIT License, for more information see the LICENSE file

  All copyright belongs to the individual owners and authors
## Scripts
- Touchpad_Toggle
- mupdf_toc
- dmenu_toc
- dmenu_books

### Touchpad_Toggle
  This simply toggles the touchpad, it also provides functions that allow you to setup your own stuff.

### MuPDF_ToC   
  This extracts and allows easy manipulation of the `mutool show outline` command for a PDF. See dmenu_ToC
for more information.

### dmenu_ToC
  This is a script that connects MuPDF_ToC to dmenu to allow for nagivation between file.

### dmenu_books
   This is a script that allows you to open up books and documentation from dmenu.
Everything is stored under ~/library for the most part. Run it with no arguments for the Librarian,
otherwise pass it in either "Browse", "Manage", "Librarian", "BookAdd", "BookRemove", "ShelfDelete", 
"ShelfCreate", "SectionCreate", or "SectionDelete" for the related functionality.

The format for all storage have the fields delimitated by tabs and are as follows:
Name    Path

For books it uses the following format:
Name    Reader    Path
