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

" Only do this when not done yet for this buffer
" if exists("g:loaded_rst_sections_ftplugin")
"     finish
" endif
" "

let loaded_rst_sections_ftplugin = 1

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

function! s:RstSeekSectionTitle()
    " Finds the right section title line.
    " Returns false if no title was found

    let initialline = line('.')

    " jump above until current is not at a white line
    while line('.') > 1 && s:RstIsWhiteLine(getline(line('.')))
        normal k
    endwhile

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
        endif
    endif
endfunction

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_rst_sections_maps")

    " ctrl-u 0: mark section without any border
    noremap <silent> <c-u>0 :call RstSetSection('0')<cr>
    inoremap <silent> <c-u>0 <esc>:call RstSetSection('0')<cr>

    " ctrl-u 1: mark section as part
    noremap <silent> <c-u>1 :call RstSetSection('1')<cr>
    inoremap <silent> <c-u>1 <esc>:call RstSetSection('1')<cr>

    " Ctrl-U 2: mark section as chapter
    noremap <silent> <C-u>2 :call RstSetSection(2)<CR>
    inoremap <silent> <C-u>2 <esc>:call RstSetSection(2)<CR>

    " Ctrl-U 3: mark section as level =
    noremap <silent> <C-u>3 :call RstSetSection(3)<CR>
    inoremap <silent> <C-u>3 <esc>:call RstSetSection(3)<CR>

    " Ctrl-U 4: mark section as level -
    noremap <silent> <C-u>4 :call RstSetSection(4)<CR>
    inoremap <silent> <C-u>4 <esc>:call RstSetSection(4)<CR>

    " Ctrl-U 5: mark section as level ^
    noremap <silent> <C-u>5 :call RstSetSection(5)<CR>
    inoremap <silent> <C-u>5 <esc>:call RstSetSection(5)<CR>

    " Ctrl-U 6: mark section as level "
    noremap <silent> <C-u>6 :call RstSetSection(6)<CR>
    inoremap <silent> <C-u>6 <esc>:call RstSetSection(6)<CR>
endif

