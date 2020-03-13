if exists('g:vscode')
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


    map <c-j> }
    map <c-k> {

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

    " Move faster vertically (paragraph motion)
    map <c-j> }
    map <c-k> {

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


    "Commentary
	xmap gc  <Plug>VSCodeCommentary
	nmap gc  <Plug>VSCodeCommentary
	omap gc  <Plug>VSCodeCommentary
	nmap gcc <Plug>VSCodeCommentaryLine

    " plugin via vim-plug
    call plug#begin()
        Plug 'tpope/vim-surround'
        Plug 'wellle/targets.vim'
    call plug#end()

endif
