if vim.g.vscode then
     -- VSCode extension
    local map = vim.api.nvim_set_keymap
    local default_opts = { noremap = true, silent = true  }
    local cmd = vim.cmd
    local opt = vim.opt

    --################################################
    -- Settings and options
    --################################################
    opt.clipboard               = 'unnamed,unnamedplus'         -- Default to system clipboard

    --################################################
    -- Action 
    -- source : https://github.com/sokhuong-uon/vscode-nvim/blob/main/init.lua
    --################################################

    local file = {
      save = function()
        vim.fn.VSCodeNotify("workbench.action.files.save")
      end,
      format = function()
        vim.fn.VSCodeNotify("editor.action.formatDocument")
      end,
    }

    -- https://vi.stackexchange.com/a/31887
    local nv_keymap = function(lhs, rhs)
      vim.api.nvim_set_keymap('n', lhs, rhs, { noremap = true, silent = true })
      vim.api.nvim_set_keymap('v', lhs, rhs, { noremap = true, silent = true })
    end

    local nx_keymap = function(lhs, rhs)
      vim.api.nvim_set_keymap('n', lhs, rhs, { silent = true })
      vim.api.nvim_set_keymap('v', lhs, rhs, { silent = true })
    end

    --################################################
    --Keymap
    --################################################
    vim.g.mapleader = " "

    -- Find in files for word under cursor (experimental)
    map('n', '?', [[<Cmd>call VSCodeNotify('workbench.action.findInFiles', { 'query': expand('<cword>')})<CR>]], default_opts)

    -- Clear search highlighting
    map('', '<space><space>', ':nohl<CR>', {silent = true})

    -- File operations
    vim.keymap.set({ 'n', 'v' }, "<space>w", file.save)
    vim.keymap.set({ 'n', 'v' }, "<space>f", file.format)

    -- H and L Begin/End on homerow
    map('n', 'H', '^'  , {noremap =false, silent = true})
    map('n', 'L', 'g_'  , {noremap =false, silent = true})

    -- Repeat . command in visual mode
    map('v', '.', ':normal.<CR>', {noremap = true})

    -- Keep selection in select mode after shifting
    -- Indenting not working when the line starts with ##
    map('v', '>', '>gv', default_opts)
    map('v', '<', '<gv', default_opts)

    -- " Reselect last insertext
    map('n', 'gV','`[v`]', default_opts)

    -- " Quick yanking to the end of the line
    map('n', 'Y', 'y$', default_opts)

    -- " Quick macro recording and replaying ,qq for recording, and Q for replaying
    map('n', 'Q', '@q', default_opts)
    map('x', 'Q', ':normal @q<CR>', default_opts)

    -- Map some keys for azerty keyboard
    map('n', 'µ', '#'  , {noremap =false, silent = true})
    map('n', '²', '.'  , {noremap =false, silent = true})

    -- Marks keepjumps
    map('n', 'mù','m`', default_opts)
    map('n', 'ùù','``', default_opts)
    map('n', '\'','`', default_opts)

    -- -- Increment / Decrement
    map('n', '+','<C-a>', default_opts)
    map('n', '-','<C-x>', default_opts)
    map('x', '+','<C-a>', default_opts)
    map('x', '-','<C-x>', default_opts)

    -- " Indent/Format All documents using = or gq
    map('n', 'g=','mmgg=G`m', default_opts)
    map('n', 'gQ','mmgggqG`m', default_opts)

    -- " Change word under cursor and dot repeat, really useful to edit quickly
    map('n', 'c*' , '*Ncgn' , default_opts)
    map('n', 'c#' , '#NcgN' , default_opts)
    map('n', 'cg*', 'g*Ncgn', default_opts)
    map('n', 'cg#', 'g#Ncgn', default_opts)


    -- " Move through windows
    map('n','<C-j>',[[:call VSCodeNotify('workbench.action.navigateDown')<CR>]], default_opts)
    map('x','<C-j>',[[:call VSCodeNotify('workbench.action.navigateDown')<CR>]], default_opts)

    map('n','<C-k>',[[:call VSCodeNotify('workbench.action.navigateUp')<CR>]], default_opts)
    map('x','<C-k>',[[:call VSCodeNotify('workbench.action.navigateUp')<CR>]], default_opts)

    map('n','<C-h>',[[:call VSCodeNotify('workbench.action.navigateLeft')<CR>]], default_opts)
    map('x','<C-h>',[[:call VSCodeNotify('workbench.action.navigateLeft')<CR>]], default_opts)
     
    map('n','<C-l>',[[:call VSCodeNotify('workbench.action.navigateRight')<CR>]], default_opts)
    map('x','<C-l>',[[:call VSCodeNotify('workbench.action.navigateRight')<CR>]], default_opts)

    -- Commentary
    map('n', 'gc', '<Plug>VSCodeCommentary'  , {noremap =false, silent = true})
    map('x', 'gc', '<Plug>VSCodeCommentary'  , {noremap =false, silent = true})
    map('o', 'gc', '<Plug>VSCodeCommentary'  , {noremap =false, silent = true})
    map('n', 'gcc', '<Plug>VSCodeCommentaryLine'  , {noremap =false, silent = true})
    
    --################################################
    -- Text-Objects
    --################################################

    -- Line text-object
    -------------------
    -- il al
    map('x', 'il','g_o0', default_opts)
    map('o', 'il',':<C-u>normal vil<CR>', default_opts)
    map('x', 'al','$o0', default_opts)
    map('o', 'al',':<C-u>normal val<CR>', default_opts)

    -- Buffer(entire)
    -------------------
    -- ie ae
    map('x', 'ie','GoggV', default_opts)
    map('o', 'ie',':<C-u>normal mzvie<CR>`z', default_opts)
    map('x', 'ae','GoggV', default_opts)
    map('o', 'ae',':<C-u>normal mzvae<CR>`z', default_opts)

    -- Right Angle and Angle Bracket text-object
    ---------------------------------------------
    -- ir ar
    map('x', 'ir','i[', default_opts)
    map('o', 'ir',':<C-u>normal vi[<CR>', default_opts)
    map('x', 'ar','a[', default_opts)
    map('o', 'ar',':<C-u>normal va[<CR>', default_opts)

    -- " ia aa
    map('x', 'ia','i>', default_opts)
    map('o', 'ia',':<C-u>normal vi><CR>', default_opts)
    map('x', 'aa','a>', default_opts)
    map('o', 'aa',':<C-u>normal va><CR>', default_opts)


    --################################################
    -- Autocommand
    --################################################
    vim.cmd ([[
            " Highlight yank
            augroup highlight_yank
                autocmd!
                autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup="IncSearch", timeout=300 }
            augroup END
        ]])

    --################################################
    --Plugins
    --################################################
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            lazypath,
        })
    end

    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
        -----------------------------------------------------------
        -- Buffer Helpers
        -----------------------------------------------------------
        -- tim pope plugins
        'tpope/vim-surround',

        --  repeat surround action
        'tpope/vim-repeat',

        -- vim-exchange exchange lines
        {
            "tommcdo/vim-exchange",
            keys = {
                { "cx" },
                { "X" , mode = "x" },
            },
        },

        -- transpose
        -- If not working on *unix
        -- Convert plugin/transpose.vim and autoload/transpose.vim with dos2unix
        {
            "vim-scripts/Transpose",
            cmd = {
                "Transpose", "TransposeWords", "TransposeCSV", "TransposeTab", "TransposeInteractive"
            },
        },

        -- Align based on character (mapping gl)
        {
            'tommcdo/vim-lion',
            keys = {
                { "gl" },
                { "gl" , mode = "x" },
            },
        },

        -- Aligning (mapping ga , replace gl when config is stable)
        {
            "junegunn/vim-easy-align",
            config = function()
                -- require "rmagatti.easyalign"
                vim.cmd [[
                    " Start interactive EasyAlign in visual mode (e.g. vipga)
                    xmap ga <Plug>(EasyAlign)
                    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
                    nmap ga <Plug>(EasyAlign)
                    " Align GitHub-flavored Markdown tables
                    augroup aligning
                    au!
                    au FileType markdown vmap <leader><Bslash> :EasyAlign*<bar><CR>
                    augroup end
                    ]]
            end,
            keys = {
                { "ga" },
                { "ga" , mode = "x" },
            },
            cmd = { "EasyAlign" },
        },

        -- vim-sort-motion (mapping gs)
        {
            "christoomey/vim-sort-motion",
            keys = {
                { "gss" },
                { "gs" },
                { "gs" , mode = "x" },
            },
        },

        -- Replace with Register
        {
            'vim-scripts/ReplaceWithRegister'
        },

        -- Text objects
        { 'coderifous/textobj-word-column.vim' },
        { 'michaeljsmith/vim-indent-object' },
        {
            "wellle/targets.vim",
            event = { "BufReadPost" },
        },

        -----------------------------------------------------------
        -- Helpers
        -----------------------------------------------------------
        -- lightspeed (Advantage : the label is on the third char)
        {
            'ggandor/lightspeed.nvim',
            config = function()
                require 'lightspeed'.setup {
                    labels = { "s", "f", "n", "j", "k", "l", "o", "i", "w", "e", "h", "g", "u", "t", "m", "v", "c", "a", "z" }
                }

                --disabling f F t T
                vim.api.nvim_set_keymap("n", "f", "f", { silent = true })
                vim.api.nvim_set_keymap("n", "F", "F", { silent = true })
                vim.api.nvim_set_keymap("n", "t", "t", { silent = true })
                vim.api.nvim_set_keymap("n", "T", "T", { silent = true })

            end
        },
     })
else
    -- ordinary Neovim
end
