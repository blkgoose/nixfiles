opt = vim.opt
cmd = vim.cmd
g = vim.g
fn = vim.fn

function _G.nmap(shortcut, command)
    vim.api.nvim_set_keymap('n', shortcut, command, { noremap = true, silent = true })
end

function _G.imap(shortcut, command)
    vim.api.nvim_set_keymap('i', shortcut, command, { noremap = true, silent = true })
end

function _G.keymap(key, fun)
    vim.keymap.set('n', key, fun, {})
end

function _G.reload_conf()
    cmd [[ Reload ]]
    cmd [[ PackerCompile ]]
end
