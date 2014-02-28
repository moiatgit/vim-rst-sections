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
if exists("g:loaded_rst_sections_ftplugin")
    finish
endif
"

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
            normal jdd
        endif
        if line('.') < line('$') 
            normal k
            if ! s:RstIsWhiteLine(getline(line('.')+1))
                normal ok
            endif
        endif
    endif
endfunction

function! RstSetSection(level)
    " sets current line borders
    " level 0: no borders at all
    " level 1-2: borders above and below (#, *)
    " level 3-6: just border below (=, -, ^, ")
    " any other: do nothing
    if a:level >= 0 && a:level <= 6
        " clean possible previous level or malformed section line
        call s:RstSetEmptyLineBelow()
        call s:RstSetEmptyLineAbove()

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
endfunction

" Add mappings, unless the user didn't want this.
if !exists("no_plugin_maps") && !exists("no_rst_sections_maps")

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
endif
