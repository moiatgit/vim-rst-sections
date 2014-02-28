rst-sections
============

This small vim plug-in is named after matthew-brett's vim-rst-sections
plug-in. I've completely rewritten it and dropped some features on the
way. Please, review Mattew's original plug-in for these features at
https://github.com/matthew-brett/vim-rst-sections.

On the other hand, maps are inspired by a post fount at (currently
unavailable) blog address:
http://blog.tuxcoder.com/2008/12/11/vim-restructuretext-macros/

Description
-----------

This plug-in offers the function *RstSetSection(level)* that accepts
an integer from 0 to 6.

* Level 0: normal section (no section borders above nor below)

* Level 1: part section (borders with # above and below)

* Level 2: chapter section (as level 1 but with * character)

* Level 3: section border below with =

* Level 4: same as level 3 but with - character

* Level 5: same as level 3 but with ^ character

* Level 6: same as level 3 but with " character

Installation
------------

If you are using *Vundle* you can add the following line to your
.vimrc

    Bundle 'git@github.com:moiatgit/vim-rst-sections.git'

Do not forget to ask Bundle to install it in a vim session:

    :BundleInstall

Otherwise, you can install it simply by copying the file
*rst_sections.vim* at your .vim/ftplugin folder.


Usage
-----

To use RstSetSection(level), just place cursor on the line you want to
convert to a certain section level and call the function. For example:

    :call RstSetSection(1)

You may want to create some direct access to this function. I use the
following:

    " Ctrl-U 1: underline Parts w/ #'s
    noremap <silent> <C-u>0 :call RstSection('0')<CR>
    inoremap <silent> <C-u>0 <esc> :call RstSection('0')<CR>

    " Ctrl-U 1: underline Parts w/ #'s
    noremap <silent> <C-u>1 :call RstSection('1')<CR>
    inoremap <silent> <C-u>1 <esc> :call RstSection('1')<CR>

    " Ctrl-U 2: underline Chapters w/ *'s
    noremap <silent> <C-u>2 :call RstSection(2)<CR>
    inoremap <silent> <C-u>2 <esc> :call RstSection(2)<CR>

    " Ctrl-U 3: underline Section Level 1 w/ ='s
    noremap <silent> <C-u>3 :call RstSection(3)<CR>
    inoremap <silent> <C-u>3 <esc> :call RstSection(3)<CR>

    " Ctrl-U 4: underline Section Level 2 w/ -'s
    noremap <silent> <C-u>4 :call RstSection(4)<CR>
    inoremap <silent> <C-u>4 <esc> :call RstSection(4)<CR>

    " Ctrl-U 5: underline Section Level 3 w/ ^'s
    noremap <silent> <C-u>5 :call RstSection(5)<CR>
    inoremap <silent> <C-u>5 <esc> :call RstSection(5)<CR>

    " Ctrl-U 6: underline Section Level 4 w/ ~'s
    noremap <silent> <C-u>6 :call RstSection(6)<CR>
    inoremap <silent> <C-u>6 <esc> :call RstSection(6)<CR>

License
-------

You can do whatever you want with this plug-in
under the terms of the GNU General Public License
as published by the Free Software Foundation,
either version 3 of the License, or any later version (your choice)
