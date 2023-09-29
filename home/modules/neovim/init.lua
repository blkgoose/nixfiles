require("utils")

opt.number = true
opt.wrap = false
opt.showmatch = true
opt.hidden = true

opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.completeopt = "menu"
opt.autoindent = true
opt.expandtab = true
opt.shiftwidth = 4
opt.smarttab = true
opt.softtabstop = 4
opt.relativenumber = true
opt.cursorline = true

opt.laststatus = 2
opt.guicursor = "i:block"
opt.termguicolors = true
opt.pumheight = 12

opt.mouse = ""

cmd([[
    let s:pair_mode = 1
    function! PairMode()
        let currwin=winnr()

        if s:pair_mode  == 1
            let s:pair_mode = 0
            windo set norelativenumber
        else
            let s:pair_mode = 1
            windo set relativenumber
        endif
        execute currwin . 'wincmd w'
    endfunction

    nnoremap <leader>P :call PairMode()<CR>
]])

nmap("cf", ":!touch <cfile><cr>")
nmap("*", '"syiw<Esc>: let @/ = @s<CR>:set hlsearch<CR>')
nmap("<F1>", ':let @/ = ""<CR>')

opt.clipboard = "unnamed,unnamedplus"

-- highlight what has been copied
cmd([[
autocmd TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=500 }
]])

cmd([[
nnoremap <C-c> [{V%
xnoremap <C-c> "_y[{V%
]])

require("plugins")
