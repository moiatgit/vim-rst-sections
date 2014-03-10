" reStructuredText sections plugin
" Language:     VimScript
" Maintainer:   Moisès Gómez
" Version:      0.1
" URL:          http://github.com/moiatgit/vim-rst-sections
"
" VimVersion:   Vim 7 (may work with lower Vim versions, but not tested)
"
" I got the structure of this plugin from
" https://github.com/matthew-brett/vim-rst-sections by Matthew Brett
" with thanks.
"

let s:types = ['#', '*', '=', '-', '^', "'" ]

function! s:RstIsSectionBorder(text)
    " returns true if text is a section border
    let result = 0
    for c in s:types
        let ch = c == '*' ? '\*':c
        let expr = '^\s*'. ch . '\+\s*$'
        let m = match(a:text, expr)
        if empty(m)
            let result = 1
            break
        endif
    endfor
    return result
endfunction

function! s:RstGetSectionLevelFromChar(ch)
    " returns section level from character ch
    " if ch doesn't correspond to any section level, it returns 0
    let result = 0
    let level = 0
    for c in s:types
        let level += 1
        if c == a:ch
            let result = level
            break
        endif
    endfor
    return result
endfunction

function! s:RstIsWhiteLine(text)
    " returns true if text is an empty line or just contains white
    " spaces
    let expr = '^\s*$'
    let m = match(a:text, expr)
    return empty(m)
endfunction

function! s:RstSetEmptyLineAbove()
    " It forces an empty line above current line.
    " If there was a section border, removes it
    let lineno = line('.')
    if line('.') > 1
        if s:RstIsSectionBorder(getline(line('.')-1))
            normal kdd
        endif
        if ! s:RstIsWhiteLine(getline(line('.')-1))
            normal Oj
        endif
    endif
endfunction

function! s:RstSetEmptyLineBelow()
    " It forces an empty line below current line
    " If there was a section border, removes it
    if line('.') < line('$')
        if s:RstIsSectionBorder(getline(line('.')+1))
            if line('.') == line('$') - 1
                normal jdd
            else
                normal jddk
            endif
        endif
        if ! s:RstIsWhiteLine(getline(line('.')+1))
            normal ok
        endif
    endif
endfunction

function! s:RstJumpWhiteLinesAbove()
    " jumps above until current is not at a white line
    while line('.') > 1 && s:RstIsWhiteLine(getline(line('.')))
        normal k
    endwhile
endfunction

function! s:RstSeekSectionTitle()
    " Finds the right section title line.
    " Returns false if no title was found

    let initialline = line('.')
    call s:RstJumpWhiteLinesAbove()
    if line('.') > 1
        " jump border line
        let currentline = getline(line('.'))
        if s:RstIsSectionBorder(getline(line('.')))
            let currentchar = currentline[0]
            if s:RstIsWhiteLine(getline(line('.')-1)) && (currentchar == '#' || currentchar == '*')
                normal j
            else
                normal k
            endif
        endif
    endif

    let titlenotfound = s:RstIsWhiteLine(getline(line('.'))) || s:RstIsSectionBorder(getline(line('.')))
    if titlenotfound
        execute initialline
    endif
    return ! titlenotfound
endfunction

function! s:RstCleanSectionTitle()
    " removes whitespaces at the end of the title
    let expr = '\s\+$'
    let currentline = getline(line('.'))
    let m = match(currentline, expr)
    if m > -1
        s/\s\+$/
    endif
endfunction

function! s:RstCleanSectionBorders()
    " cleans any possible section borders (even if they're malformed)
    call s:RstSetEmptyLineBelow()
    call s:RstSetEmptyLineAbove()
endfunction

function! s:RstSetSectionLevel(level)
    " sets section level for current line
    " returns 1 if done
    let result = 0
    if a:level >= 0 && a:level <= 6
        if s:RstSeekSectionTitle()
            call s:RstCleanSectionTitle()
            call s:RstCleanSectionBorders()
            if a:level > 0
                let char = s:types[a:level-1]
                " add border below
                execute 'normal yypVr' . char . 'k'
                if a:level == 1 || a:level == 2
                    " add border above
                    normal jyykPj
                endif
            endif
        endif
    endif
    return result
endfunction

function! RstSetSection(level)
    " sets current line borders
    " level 0: no borders at all
    " level 1-2: borders above and below (#, *)
    " level 3-6: just border below (=, -, ^, ")
    " any other: do nothing
    if s:RstSetSectionLevel(a:level)
        " reposition cursor
        normal 2j
    endif
endfunction

function! s:RstGetCurrentSectionChar()
    " returns current section char. Empty char if it is not a section
    " assumes cursor is at section title or at section border
    let currentchar = ""
    let currentline = getline(line('.'))
    if ! s:RstIsSectionBorder(currentline)
        let currentline = getline(line('.')+1)
    endif
    if s:RstIsSectionBorder(currentline)
        let currentchar = currentline[0]
    endif
    return currentchar
endfunction

function! s:RstGetCurrentSectionLevel()
    " returns the current section level
    let sectionchar = s:RstGetCurrentSectionChar()
    return s:RstGetSectionLevelFromChar(sectionchar)
endfunction

function! s:RstGetTitleLineofASection(lineno)
    " returns the line corresponding to the title of a section in
    " the lineno or 0 if it is not a section at all.
    " lineno must be the title or any border of a section.
    " It doesn't have to be a well formed section. With some border
    " below/above a non white line it suffices
    let result = 0
    let currentline = getline(a:lineno)
    if ! s:RstIsWhiteLine(currentline)
        if s:RstIsSectionBorder(currentline)
            if ! s:RstIsWhiteLine(getline(a:lineno - 1))
                let result = a:lineno - 1
            elseif ! s:RstIsWhiteLine(getline(a:lineno + 1))
                let result = a:lineno + 1
            endif
        elseif s:RstIsSectionBorder(getline(a:lineno - 1)) || s:RstIsSectionBorder(getline(a:lineno + 1)) 
            let result = a:lineno
        endif
    endif
    return result
endfunction

function! RstGoPrevSection()
    " sets current line to the previous section (is circular)
    let initline = line('.')

    while 1
        " current line can't be next section
        normal k

        " search next section border 
        execute "silent! ?^[-#*=^']\\+$"
        if ! s:RstIsSectionBorder(getline(line('.')))
            execute initline
            break
        endif

        let lineno = s:RstGetTitleLineofASection(line('.'))
        if lineno != 0
            execute lineno
            break
        endif
    endwhile
endfunction

function! RstGoNextSection()
    " sets current line to the next section (is circular)
    let initline = line('.')

    while 1
        " current line can't be next section
        normal j

        " search next section border 
        execute "silent! /^[-#*=^']\\+$"
        if ! s:RstIsSectionBorder(getline(line('.')))
            execute initline
            break
        endif

        let lineno = s:RstGetTitleLineofASection(line('.'))
        if lineno != 0
            execute lineno
            break
        endif
    endwhile
endfunction

function! RstIncrSectionLevel()
    " increments the level of the section at current line
    " If no section at current line, it assumes level 0
    " Well formed section is not required. It assumes 
    " section border below as level guide.
    if s:RstSeekSectionTitle()
        let currentlevel = s:RstGetCurrentSectionLevel()
        let newlevel = currentlevel - 1
        if newlevel < 0
            let newlevel = len(s:types)
        endif
        call RstSetSection(newlevel)
    endif
endfunction

function! RstDecrSectionLevel()
    " decrements the level of the section at current line
    " If no section at current line, it assumes level 0
    " Well formed section is not required. It assumes 
    " section border below as level guide.
    if s:RstSeekSectionTitle()
        let currentlevel = s:RstGetCurrentSectionLevel()
        let newlevel = (currentlevel + 1) % (len(s:types) + 1)
        call RstSetSection(newlevel)
    endif
endfunction

function! s:RstGetLabel()
    " returns the label of the current line
    " A label is a string followed by a white space, followed by a
    " number (one or more digits) or sign '#', and then followed by a
    " dot and a white space.
    let expr  = '^\zs.\{-\}\ze \(\(\d\+\)\|#\)\. '
    let text  = getline(line('.'))
    let label = matchstr(text, expr)
    return label
endfunction

function! RstSectionLabelize()
    " Considers current line started by a label followed by a number
    " otherwise ends without effect.
    " Once the label is identified, it searches the first time the
    " label appears at the buffer and formats the rest of the lines
    " starting with this label in the following way:
    "   - renumbers sequentially from first label appearance
    "   - copies the section level of the first label
    let label = s:RstGetLabel()
    if label != ""
        let exprtitle = '^' . label .  ' \(\(\d\+\)\|#\)\. \zs.*$'
        let currentline = line('.')
        0
        let expr = '^' . label . ' \zs\(\(\d\+\)\|#\)\ze\. '
        execute "silent normal! /" . expr . "\r"
        let firstline = line('.')
        let nr = matchstr(getline(firstline), expr)
        if nr == "#"
            let nr = 1
        endif
        let level = s:RstGetCurrentSectionLevel()
        while 1
            let title = matchstr(getline(line('.')), exprtitle)
            let newcontent = label . " " . nr . ". " . title
            execute "silent normal! 0DI" . newcontent
            call s:RstSetSectionLevel(level)
            normal 2j
            execute "silent normal! /" . expr . "\r"
            let nr = nr + 1
            if line('.') <= firstline
                break
            endif
        endwhile
        execute currentline
    endif
    " now I'm able to find out all the labels in the buffer
    " next step is to renumber labels from first nr
    " then apply section level
endfunction

" Add mappings, unless the user didn't want this.
if !exists("no_rst_sections_maps")

    " <leader> 0: mark section without any border
    noremap <silent> <leader>s0 :call RstSetSection('0')<cr>
    inoremap <silent> <leader>s0 <esc>:call RstSetSection('0')<cr>

    " <leader>s 1: mark section as part
    noremap <silent> <leader>s1 :call RstSetSection('1')<cr>
    inoremap <silent> <leader>s1 <esc>:call RstSetSection('1')<cr>

    " <leader>s 2: mark section as chapter
    noremap <silent> <leader>s2 :call RstSetSection(2)<CR>
    inoremap <silent> <leader>s2 <esc>:call RstSetSection(2)<CR>

    " <leader>s 3: mark section as level =
    noremap <silent> <leader>s3 :call RstSetSection(3)<CR>
    inoremap <silent> <leader>s3 <esc>:call RstSetSection(3)<CR>

    " <leader>s 4: mark section as level -
    noremap <silent> <leader>s4 :call RstSetSection(4)<CR>
    inoremap <silent> <leader>s4 <esc>:call RstSetSection(4)<CR>

    " <leader>s 5: mark section as level ^
    noremap <silent> <leader>s5 :call RstSetSection(5)<CR>
    inoremap <silent> <leader>s5 <esc>:call RstSetSection(5)<CR>

    " <leader>s 6: mark section as level "
    noremap <silent> <leader>s6 :call RstSetSection(6)<CR>
    inoremap <silent> <leader>s6 <esc>:call RstSetSection(6)<CR>

    " <leader>s k: jumps to the previous section title
    noremap <silent> <leader>sk :call RstGoPrevSection()<CR>
    inoremap <silent> <leader>sk <esc>:call RstGoPrevSection()<CR>

    " <leader>s j: jumps to the next section title
    noremap <silent> <leader>sj :call RstGoNextSection()<CR>
    inoremap <silent> <leader>sj <esc>:call RstGoNextSection()<CR>

    " <leader>s a: increments section level
    noremap <silent> <leader>sa :call RstIncrSectionLevel()<CR>
    inoremap <silent> <leader>sa <esc>:call RstIncrSectionLevel()<CR>

    " <leader>s x: decrements section level
    noremap <silent> <leader>sx :call RstDecrSectionLevel()<CR>
    inoremap <silent> <leader>sx <esc>:call RstDecrSectionLevel()<CR>

    " <leader>s l: labelizes current line
    noremap <silent> <leader>sl :call RstSectionLabelize()<CR>
    inoremap <silent> <leader>sl <esc>:call RstSectionLabelize()<CR>

endif

