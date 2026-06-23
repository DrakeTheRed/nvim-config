vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.o.wrap = false
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

local installed_lsp = {
	"lua_ls",
	"rust_analyzer",
	"zls",
}

vim.pack.add({
	gh("windwp", "nvim-autopairs"),
	gh("rebelot", "kanagawa.nvim"),
	gh("nvim-tree", "nvim-web-devicons"),
	gh("neovim", "nvim-lspconfig"),
	gh("nvim-mini", "mini.pick"),
	gh("mason-org", "mason.nvim"),
	gh("mason-org", "mason-lspconfig.nvim"),
	gh("WhoIsSethDaniel", "mason-tool-installer.nvim"),
	gh("stevearc", "oil.nvim"),
	gh("rachartier", "tiny-inline-diagnostic.nvim"),
	gh("saghen", "blink.lib"),
	gh("saghen", "blink.cmp"),
	gh("tpope", "vim-fugitive"),
	gh("ficd0", "ashen.nvim"),
	gh("nvim-mini", "mini.statusline"),
	gh("nvim-mini", "mini.diff"),
})

require("ashen").load()
vim.cmd.colorscheme("ashen")

vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('my.lsp', {}),
	callback = function(ev)
		local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition", buf = ev.buf, remap = false })
		-- Kept just for remembering
		-- if client:supports_method('textDocument/completion') then
		-- 	   vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
		-- end
	end,
})

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.lsp.foldexpr()"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

require("mini.diff").setup({})
local msl = require('mini.statusline')
msl.setup({
	content = {
		active = function()
			local mode, mode_hl = msl.section_mode({ trunc_width = 12 })
			local filename = msl.section_filename({ trunc_width = 50 })
			local diff = msl.section_diff({ trunc_width = 10 })
			local searchcount = msl.section_searchcount({ trunc_width = 10 })

			local mode_colors = vim.api.nvim_get_hl(0, {
				name = mode_hl,
				link = false
			})
			local background = mode_colors.bg

			local devinfo_colors = vim.api.nvim_get_hl(0, {
				name = 'MiniStatuslineDevinfo',
				link = false
			})
			local devinfo_background = devinfo_colors.bg

			local branch = vim.fn.FugitiveHead()
			if not (string.len(branch) == 0) then
				branch = " " .. branch
			end

			vim.api.nvim_set_hl(0, 'StatuslineTriangleLeft', { fg = background, bg = devinfo_background })
			-- return msl.combine_groups({
			-- 	{ hl = mode_hl, strings = {filename}},
			-- 	{ hl = 'StatuslineTriangleLeft', strings = {''} },
			-- })

			local lsp_clients = (function()
				local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
				if next(buf_clients) == nil then return "" end

				local names = {}
				for _, client in ipairs(buf_clients) do
					table.insert(names, client.name)
				end
				return table.concat(names, ", ")
			end)()

			local parts = {
				string.format("%%#%s# %s %%#StatuslineTriangleLeft#", mode_hl, filename),
				string.format(" %s ", branch),
				"%=",
				string.format(" %s ", searchcount),
				(lsp_clients ~= "") 
          and string.format("%%#MiniStatuslineLsp# %s ", lsp_clients) or "",
				string.format("%%#StatuslineTriangleLeft#%%#%s# %s ", mode_hl, diff),
			}
			return table.concat(parts, "")
		end
	}
})

local hl = vim.api.nvim_set_hl
hl(0, 'MiniStatuslineModeNormal', { bg = '#df6464', fg = '#000000', bold = true })
hl(0, 'MiniStatuslineModeVisual', { bg = '#3a6363', fg = '#000000', bold = true })
hl(0, 'MiniStatuslineModeCommand', { bg = '#1e6f54', fg = '#000000', bold = true })
hl(0, 'IncSearch', { bg = '#c4693d', fg = '#000000', bold = true })

local cmp = require('blink.cmp')
cmp.build():pwait()
cmp.setup({
	completion = {
		trigger = {
			show_on_keyword = true
		},
		list = {
			selection = {
				auto_insert = true,
			}
		}
	},
	sources = {
		default = { 'lsp', 'path', 'snippets', 'buffer' }
	},
	keymap = {
		preset = 'super-tab',
	}
})

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
	ensure_installed = installed_lsp
})

vim.lsp.config("*", {
	capabilities = require('blink.cmp').get_lsp_capabilities()
})
for _, server in ipairs(installed_lsp) do
	vim.lsp.enable(server)
end

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
local mp = require("mini.pick")
mp.setup({})
vim.keymap.set("n", "<leader>pb", function()
	mp.builtin.buffers({})
end)

vim.keymap.set('t', "<C-d>", [[<C-\><C-n>]], { desc = "Detach terminal", remap = false })
vim.keymap.set('n', "<leader>lt", ":term<CR>", { desc = "Open Terminal" })
vim.keymap.set('n', "<leader>lf", vim.lsp.buf.format, { desc = "Format file" })

vim.keymap.set('n', "<leader>kb", ":bdelete!<CR>", { desc = "closes current buffer" })
vim.keymap.set('v', '<leader>d', '"_d', { desc = "Delete no yank pls" })
vim.keymap.set('n', '<leader>d', '"_dd', { desc = "Delete line no yank pls" })
vim.keymap.set('n', '<leader>rn', ':set relativenumber!<CR>', { desc = "Set relativenumber on/off" })
