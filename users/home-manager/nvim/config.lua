-- -------
-- Library
-- -------

function map (mode, shortcut, command)
vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end
function nmap(shortcut, command)
map('n', shortcut, command)
end
function imap(shortcut, command)
map('i', shortcut, command)
end

-- ------
-- Config
-- ------

vim.cmd([[
set autoindent expandtab tabstop=4 shiftwidth=4
set clipboard=unnamed
syntax on
set cc=80
colorscheme habamax
set list
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,precedes:«,extends:»
map <Space> <Leader>
]])

