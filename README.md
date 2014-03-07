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

The function is able to find out the section title when cursor is:

* just at the section title line

* at the section border below

* at the section border above (when levels 1 or 2)

* at any line above the section title line or section below border
  line, as far as all the lines until the title or border are white
  lines (i.e. matching '^\s\*$')

Once section title has been found, it replaces any possible section
border (even if malformed). Then it cleans up the title (removes
leading white spaces '\s'.) Then sets the section border corresponding
to the required level.

Finally it places the cursor two lines below the section title so
creating a new line (command o) is enough for starting to write a new
section. In case of asking for the wrong level, the user can ask for
another one from this same line and the function will change it
properly.

The plug-in also remaps some combination of keys in order to simplify
this function usage.

If you decide to accept my proposed remapping, then you just have to
press *control key* followed by *u* and then a number from 0 to 6.

**Note**: You'll have to press the number with a certain celerity.
Otherwise, Vim's default configuration will scroll window upwards in
the buffer in normal mode, and will remove from cursor to the start of
the line in insert mode.

License
-------

You can do whatever you want with this plug-in
under the terms of the GNU General Public License
as published by the Free Software Foundation,
either version 3 of the License, or any later version (your choice)
