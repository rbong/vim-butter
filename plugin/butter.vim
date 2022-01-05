" Defaults

if !exists('g:butter_settings')
    let g:butter_settings = 1
endif

if !exists('g:butter_settings_norelativenumber')
    let g:butter_settings_norelativenumber = 1
endif

if !exists('g:butter_settings_nonumber')
    let g:butter_settings_nonumber = 1
endif

if !exists('g:butter_settings_nobuflisted')
    let g:butter_settings_nobuflisted = 1
endif

if !exists('g:butter_fixes')
    let g:butter_fixes = 1
endif

if !exists('g:butter_fixes_color')
    let g:butter_fixes_color = 1
endif

if !exists('g:butter_fixes_redraw')
    let g:butter_fixes_redraw = 1
endif

if !exists('g:butter_fixes_airline_refresh')
    let g:butter_fixes_airline_refresh = 1
endif

augroup ButterPopupDefaults
    au User ButterPopupOpen setlocal winfixheight
augroup END

if !exists('g:butter_popup_options')
    let g:butter_popup_options = '++rows=20'
endif

if !exists('g:butter_split_options')
    let g:butter_split_options = ''
endif

" Internal functions

function! ButterTermCmd(cmd) abort
    if &buftype ==# 'terminal'
        exec a:cmd
    endif
endfunction

" Settings

augroup ButterSettings
    autocmd!
    if g:butter_settings && exists('##TerminalOpen')
        " numbers look bad in the terminal, disable them
        if g:butter_settings_norelativenumber
            au TerminalOpen * call ButterTermCmd('setlocal norelativenumber')
        endif
        if g:butter_settings_nonumber
            au TerminalOpen * call ButterTermCmd('setlocal nonumber')
        endif
        if g:butter_settings_nobuflisted
            " do not include the terminal buffer in lists
            au TerminalOpen * call ButterTermCmd('setlocal nobuflisted')
        endif
    endif
augroup END

" Fixes

if g:butter_fixes && has('terminal')
    " some terminal programs need *-256color to show color
    " vim only supports xterm-*
    " this could also mess with your colors, ex. ale
    if g:butter_fixes_color
        set term=xterm-256color
    endif
endif

augroup ButterFixes
    autocmd!
    if g:butter_fixes 
        " sometimes windows disappear, force them to reappear
        if exists('##TerminalOpen') && g:butter_fixes_redraw
            au Terminalopen * redraw!
        endif
        " sometimes airline fails to render properly when a terminal is opened
        if exists(':AirlineRefresh') && g:butter_fixes_airline_refresh
            au BufWinEnter * silent! AirlineRefresh
        endif
    endif
augroup END

" Commands

" start or attach to a terminal on the bottom right
function! butter#popup()
    wincmd b
    if exists('b:is_butter_terminal')
        if mode() !=# 't'
            normal! a
        endif
    else
        exec 'bot term '.g:butter_popup_options
        doautocmd User ButterPopupOpen
        let b:is_butter_terminal = 1
    endif
endfunction
" split or start a terminal on the bottom right
function! butter#split()
    wincmd b
    if exists('b:is_butter_terminal')
        exec 'rightb vertical term '.g:butter_popup_options.' '.g:butter_split_options
        doautocmd User ButterPopupOpen
        let b:is_butter_terminal = 1
    else
        call butter#popup()
    endif
endfunction
command! -nargs=0 ButterPopup :call butter#popup()
command! -nargs=0 ButterSplit :call butter#split()
