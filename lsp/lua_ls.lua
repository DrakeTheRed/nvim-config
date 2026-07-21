local capabilities = require('blink.cmp').get_lsp_capabilities()

---@type vim.lsp.Config
return {
	capabilities = capabilities,
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
}
