if exists('g:vscode')
    set clipboard^=unnamed,unnamedplus " Default to system clipboard
    " Space as a Leader key
    let mapleader = "\<Space>" 

    " Fast saving
    nmap <leader>w :w<cr>

    " Disable highlight when <space><space> is pressed
    map <silent> <space><space> :noh<cr>

    map H ^
    map L g_

    " Paste from yank register 
    xnoremap <leader>p "0p
    nnoremap <leader>p "0p

    "Paste quickly in insert mode
    inoremap <C-r><C-r> <C-r>*


    " Repeat . command in visual mode
    vnoremap . :normal.<CR>

    " Keep selection in select mode after shifting
    " Indenting not working when the line starts with ##
    vnoremap > >gv
    vnoremap < <gv

    " Reselect last insertext
    nnoremap gV `[v`]

    " Quick yanking to the end of the line
    nnoremap Y y$


    "Map some keys for azerty keyboard
    map µ # 
    map ² . 

    " Change word under cursor and dot repeat, really useful to edit quickly
    nnoremap c* *Ncgn
    nnoremap c# #NcgN


    " Buffer(entire) text-object
    " -------------------
    " ie ae
    xnoremap ie GoggV
    onoremap ie :<C-u>normal vie<CR>
    xnoremap ae GoggV
    onoremap ae :<C-u>normal vae<CR>

    " Line text-object
    " -----------------
    " il al
    xnoremap il g_o0
    onoremap il :<C-u>normal vil<CR>
    xnoremap al $o0
    onoremap al :<C-u>normal val<CR>

    " Right Angle and Angle Bracket text-object 
    " ---------------------------------------
    " ir ar
    xnoremap ir i[
    onoremap ir :<C-u>normal vi[<CR>
    xnoremap ar a[
    onoremap ar :<C-u>normal va[<CR>

    " ia aa
    xnoremap ia i>
    onoremap ia :<C-u>normal vi><CR>
    xnoremap aa a>
    onoremap aa :<C-u>normal va><CR>





    function! s:openVSCodeCommandsInVisualMode()
        normal! gv
        let visualmode = visualmode()
        if visualmode == "V"
            let startLine = line("v")
            let endLine = line(".")
            call VSCodeNotifyRange("workbench.action.showCommands", startLine, endLine, 1)
        else
            let startPos = getpos("v")
            let endPos = getpos(".")
            call VSCodeNotifyRangePos("workbench.action.showCommands", startPos[1], endPos[1], startPos[2], endPos[2], 1)
        endif
    endfunction

    function! s:openWhichKeyInVisualMode()
        normal! gv
        let visualmode = visualmode()
        if visualmode == "V"
            let startLine = line("v")
            let endLine = line(".")
            call VSCodeNotifyRange("whichkey.show", startLine, endLine, 1)
        else
            let startPos = getpos("v")
            let endPos = getpos(".")
            call VSCodeNotifyRangePos("whichkey.show", startPos[1], endPos[1], startPos[2], endPos[2], 1)
        endif
    endfunction


    command! -complete=file -nargs=? Split call <SID>split('h', <q-args>)
    command! -complete=file -nargs=? Vsplit call <SID>split('v', <q-args>)
    command! -complete=file -nargs=? New call <SID>split('h', '__vscode_new__')
    command! -complete=file -nargs=? Vnew call <SID>split('v', '__vscode_new__')
    command! -bang Only if <q-bang> == '!' | call <SID>closeOtherEditors() | else | call VSCodeNotify('workbench.action.joinAllGroups') | endif


    " Better Navigation
    nnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
    xnoremap <silent> <C-j> :call VSCodeNotify('workbench.action.navigateDown')<CR>
    nnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
    xnoremap <silent> <C-k> :call VSCodeNotify('workbench.action.navigateUp')<CR>
    nnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
    xnoremap <silent> <C-h> :call VSCodeNotify('workbench.action.navigateLeft')<CR>
    nnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>
    xnoremap <silent> <C-l> :call VSCodeNotify('workbench.action.navigateRight')<CR>

    " whichkey , need whichkey extension in vscode
    nnoremap <silent> , :call VSCodeNotify('whichkey.show')<CR>
    xnoremap <silent> , :<C-u>call <SID>openWhichKeyInVisualMode()<CR>

    "Commentary
    xmap gc  <Plug>VSCodeCommentary
    nmap gc  <Plug>VSCodeCommentary
    omap gc  <Plug>VSCodeCommentary
    nmap gcc <Plug>VSCodeCommentaryLine

    " plugin via vim-plug
    call plug#begin()
    Plug 'tpope/vim-surround'
    Plug 'wellle/targets.vim'
    Plug 'tommcdo/vim-exchange'
    Plug 'vim-scripts/ReplaceWithRegister'
    Plug 'tpope/vim-abolish'
    call plug#end()
endif
