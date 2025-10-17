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

opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

opt.mouse = ""

local lsp_path = vim.fs.joinpath(vim.fn.stdpath("config"), "lsp")
local lsps = {}
for fname, _ in vim.fs.dir(lsp_path) do
    lsps[#lsps + 1] = fname:match("^([^/]+).lua$")
end
vim.lsp.enable(lsps)

vim.diagnostic.config({
    float = { border = "rounded" },
    underline = true,
    virtual_text = true,
    virtual_lines = false,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf)
        end

        if
            client
            and not client:supports_method("textDocument/willSaveWaitUntil")
            and client:supports_method("textDocument/formatting")
        then
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                end,
            })
        end

        vim.lsp.inlay_hint.enable()

        -- Keymaps
        local bufopts = { buffer = args.buf, noremap = true, silent = true }
        local opts = { buffer = args.buf }

        vim.keymap.set("n", "<leader>h", vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set("n", "<leader>R", vim.lsp.buf.rename, bufopts)
        vim.keymap.set("n", "<space>j", vim.diagnostic.goto_next, bufopts)
        vim.keymap.set("n", "<space>k", vim.diagnostic.goto_prev, bufopts)
        vim.keymap.set({ "n", "v" }, "<leader>c", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
        end, opts)
    end,
})

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

cmd([[ colorscheme retrobox ]])

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
