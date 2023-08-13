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

if !exists('g:butter_neovim_compatibility')
    let g:butter_neovim_compatibility = 1
endif

if !exists('g:butter_neovim_compatibility_mappings')
    let g:butter_neovim_compatibility_mappings = 1
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

if !exists('g:butter_popup_cmd')
    let g:butter_popup_cmd = 'bash'
endif

if !exists('g:butter_popup_height')
    let g:butter_popup_height = 20
endif

" Internal functions

function! ButterTermCmd(cmd) abort
    if &buftype ==# 'terminal'
        exec a:cmd
    endif
endfunction

function! ButterTermOpenAutoCmd(cmd) abort
    let l:event = ''

    if exists('##TerminalOpen')
        let l:event = 'TerminalOpen'
    elseif exists('##TermOpen')
        let l:event = 'TermOpen'
    else
        return
    endif

    exec 'au '.l:event.' * '.a:cmd
endfunction

" Settings

augroup ButterSettings
    autocmd!
    if g:butter_settings
        " numbers look bad in the terminal, disable them
        if g:butter_settings_norelativenumber
            call ButterTermOpenAutoCmd('setlocal norelativenumber')
        endif
        if g:butter_settings_nonumber
            call ButterTermOpenAutoCmd('setlocal nonumber')
        endif
        if g:butter_settings_nobuflisted
            " do not include the terminal buffer in lists
            call ButterTermOpenAutoCmd('setlocal nobuflisted')
        endif
    endif
augroup END

" Neovim compatibility

if g:butter_neovim_compatibility && g:butter_neovim_compatibility_mappings
    tmap <c-w>" <c-\><c-n><c-r>
    tmap <c-w> <c-\><c-n><c-w>
endif

augroup ButterNeovimCompatibility
    autocmd!
    if g:butter_neovim_compatibility
        " start insert automatically
        au TermOpen * startinsert
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
        if g:butter_fixes_redraw
            call ButterTermOpenAutoCmd('redraw!')
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
        if has('nvim')
            exec 'bot '.g:butter_popup_height.'sp term://'.g:butter_popup_cmd
        else
            exec 'bot term ++rows='.g:butter_popup_height.' '.g:butter_popup_cmd
        endif
        doautocmd User ButterPopupOpen
        let b:is_butter_terminal = 1
    endif
endfunction

" split or start a terminal on the bottom right
function! butter#split()
    wincmd b
    if exists('b:is_butter_terminal')
        if has('nvim')
            exec 'rightb vertical sp term:// '.g:butter_popup_cmd
        else
            exec 'rightb vertical term '.g:butter_popup_cmd
        endif
        doautocmd User ButterPopupOpen
        let b:is_butter_terminal = 1
    else
        call butter#popup()
    endif
endfunction

" popup autocommands
augroup ButterPopupNeovimCompatibility
    autocmd!
    if g:butter_neovim_compatibility
        " autoclose terminal on success
        au TermClose * if getbufvar(expand('<abuf>'), 'is_butter_terminal') && !v:event.status | exe 'silent! bdelete! '.expand('<abuf>') | endif
    endif
augroup END

" define commands
command! -nargs=0 ButterPopup :call butter#popup()
command! -nargs=0 ButterSplit :call butter#split()
