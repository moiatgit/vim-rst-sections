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


function! RstSetSection(level)
    " sets current line borders
    " level 0: no borders at all
    " level 1-2: borders above and below (#, *)
    " level 3-6: just border below (=, -, ^, ")
    " any other: do nothing
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
            normal 2j
        endif
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

function! RstGoPrevSection()
    " sets current line to the previous section (is circular)
    let initline = line('.')

    " check case current line is border section
    if s:RstIsSectionBorder(getline(initline))
        normal k
    elseif s:RstIsSectionBorder(getline(line('.')-1)) && s:RstIsSectionBorder(getline(line('.')+1))
        " case currrent line is section title for levels 1 or 2
        normal 2k
    endif

    " search previous section border 
    ?^[-#*=^']\+$

    if s:RstIsSectionBorder(getline(line('.')))
        normal k
    else
        execute initline
    endif
endfunction

function! RstGoNextSection()
    " sets current line to the next section (is circular)
    let initline = line('.')

    " current paragraph can't be next section
    normal )

    " search next section border 
    /^[-#*=^']\+$

    if s:RstIsSectionBorder(getline(line('.')))
        let currentchar = getline(line('.'))[0]
        if currentchar == '#' || currentchar == '*'
            normal j
        else
            normal k
        endif
    endif
endfunction

function! RstIncrSectionLevel()
    " increments the level of the section at current line
    " If no section at current line, it assumes level 0
    " Well formed section is not required. It assumes 
    " section border below as level guide.
    if s:RstSeekSectionTitle()
        let currentchar = s:RstGetCurrentSectionChar()
        let currentlevel = s:RstGetSectionLevelFromChar(currentchar)
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
        let currentchar = s:RstGetCurrentSectionChar()
        let currentlevel = s:RstGetSectionLevelFromChar(currentchar)
        let newlevel = (currentlevel + 1) % (len(s:types) + 1)
        call RstSetSection(newlevel)
    endif
endfunction

" Add mappings, unless the user didn't want this.

if !exists("no_rst_sections_maps")

    " <leader> 0: mark section without any border
    noremap <silent> <leader>0 :call RstSetSection('0')<cr>
    inoremap <silent> <leader>0 <esc>:call RstSetSection('0')<cr>

    " <leader> 1: mark section as part
    noremap <silent> <leader>1 :call RstSetSection('1')<cr>
    inoremap <silent> <leader>1 <esc>:call RstSetSection('1')<cr>

    " <leader> 2: mark section as chapter
    noremap <silent> <leader>2 :call RstSetSection(2)<CR>
    inoremap <silent> <leader>2 <esc>:call RstSetSection(2)<CR>

    " <leader> 3: mark section as level =
    noremap <silent> <leader>3 :call RstSetSection(3)<CR>
    inoremap <silent> <leader>3 <esc>:call RstSetSection(3)<CR>

    " <leader> 4: mark section as level -
    noremap <silent> <leader>4 :call RstSetSection(4)<CR>
    inoremap <silent> <leader>4 <esc>:call RstSetSection(4)<CR>

    " <leader> 5: mark section as level ^
    noremap <silent> <leader>5 :call RstSetSection(5)<CR>
    inoremap <silent> <leader>5 <esc>:call RstSetSection(5)<CR>

    " <leader> 6: mark section as level "
    noremap <silent> <leader>6 :call RstSetSection(6)<CR>
    inoremap <silent> <leader>6 <esc>:call RstSetSection(6)<CR>

    " <leader> k: jumps to the previous section title
    noremap <silent> <leader>k :call RstGoPrevSection()<CR>
    inoremap <silent> <leader>k <esc>:call RstGoPrevSection()<CR>

    " <leader> j: jumps to the next section title
    noremap <silent> <leader>j :call RstGoNextSection()<CR>
    inoremap <silent> <leader>j <esc>:call RstGoNextSection()<CR>

    " <leader> a: increments section level
    noremap <silent> <leader>a :call RstIncrSectionLevel()<CR>
    inoremap <silent> <leader>a <esc>:call RstIncrSectionLevel()<CR>

    " <leader> x: decrements section level
    noremap <silent> <leader>x :call RstDecrSectionLevel()<CR>
    inoremap <silent> <leader>x <esc>:call RstDecrSectionLevel()<CR>

endif

