vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.signcolumn = "yes:1"
vim.opt.winborder = "rounded"
vim.o.scrolloff = 999

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.swapfile = false

vim.cmd("set completeopt+=noselect")
vim.diagnostic.config({
	update_in_insert = true
})

function gh(author, name)
	return "https://github.com/" .. author .. "/" .. name
end

vim.pack.add({
	gh("windwp", "nvim-autopairs"),
	gh("rebelot", "kanagawa.nvim"),
	gh("nvim-tree", "nvim-web-devicons"),
	gh("nvim-lualine", "lualine.nvim"),
	gh("neovim", "nvim-lspconfig"),
	gh("nvim-mini", "mini.pick"),
	gh("mason-org", "mason.nvim"),
	gh("mason-org", "mason-lspconfig.nvim"),
	gh("WhoIsSethDaniel", "mason-tool-installer.nvim"),
	gh("stevearc", "oil.nvim"),
	gh("rachartier", "tiny-inline-diagnostic.nvim"),
	gh("tpope", "vim-fugitive"),
})

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, {desc = "Go to definition", buf = ev.buf, remap = false})
		if client:supports_method('textDocument/completion') then
			vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		end
	end,
})
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

local oil = require("oil")
oil.setup({
	float = {
		max_width = 0.5,
		max_height = 0.5,
		border = "rounded"
	},
	view_options = {
		show_hidden = true
	}
})
vim.keymap.set("n", "<leader>pf", function()
	oil.open_float(vim.fn.getcwd())
end, { desc = "Opens Oil in cwd" })

require("tiny-inline-diagnostic").setup({
	preset = "minimal",
	options = {
		enable_on_insert = true,
		enable_on_select = true,
		multilines = {
			enabled = true,
			always_show = true,
		}
	}
})

require("mason").setup({})
require("mason-lspconfig").setup({})
require("mason-tool-installer").setup({
	ensure_installed = {
		"lua_ls",
		"rust_analyzer",
		"zls"
	}
})

vim.lsp.config('lua_ls', {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT"
			},
			diagnostics = {
				globals = {
					'vim',
					'require'
				}
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true)
			},
			telemetry = {
				enable = false
			},
		}
	}
})

require("nvim-autopairs").setup({})
require("lualine").setup({
	options = {
		theme = "palenight",
		icons_enabled = true,
		section_separators = { left = '', right = '' },
		component_separators = { left = '|', right = '|' }
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { 'branch', 'diagnostics', 'buffers' },
		lualine_c = {},
		lualine_x = {},
		lualine_y = { 'diff', 'lsp_status' },
		lualine_z = { 'progress', 'location' },
	}
})

local mp = require("mini.pick")
mp.setup({})
vim.keymap.set("n", "<leader>pb", function()
	mp.builtin.buffers({})
end)

vim.cmd.colorscheme("kanagawa")

vim.keymap.set('i', "<C-Space>", '<C-x><C-o>', { desc = "Show suggestions" })
vim.keymap.set("i", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>"
end, { expr = true })

vim.keymap.set("i", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true })

vim.keymap.set('t', "<leader>d", [[<C-\><C-n>]], { desc = "Detach from terminal" })
vim.keymap.set('n', "<leader>lt", ":term<CR>", { desc = "Open Terminal" })
vim.keymap.set('n', "<leader>lf", vim.lsp.buf.format, { desc = "Format file" })
vim.keymap.set('n', "<leader>h", vim.lsp.buf.hover, { desc = "Hover" })

vim.keymap.set('n', "<leader>kb", ":bdelete!<CR>", { desc = "closes current buffer" })
vim.keymap.set('v', '<leader>d', '"_d', { desc = "Delete no yank pls" })
vim.keymap.set('n', '<leader>d', '"_dd', { desc = "Delete line no yank pls" })
vim.keymap.set('n', '<leader>rn', ':set relativenumber!<CR>', { desc = "Set relativenumber on/off" })
