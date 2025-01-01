-- SPACE as leader key in normal mode
vim.keymap.set("n", "<SPACE>", "<Nop>")
-- Save current file
vim.keymap.set("n", "<leader>w", ":w<CR>")
-- Quit current file
vim.keymap.set("n", "<leader>q", ":q<CR>")
-- Reload vim configuration
vim.keymap.set("n", "<leader>r", ":so $MYVIMRC<CR>")

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>")
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>")
vim.keymap.set("n", "<leader>bs", ":buffers<CR>:buffer ")
