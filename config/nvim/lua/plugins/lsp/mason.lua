local cache = nil

local ensure_lsp_installs = function()
	if cache then
		return cache
	end

	local lsp_servers = require("core.utils.lsp_servers")

	local ensure_installed = {}

	for server_name, config in pairs(lsp_servers) do
		if config.auto_install ~= false then
			table.insert(ensure_installed, server_name)
		end
	end

	cache = ensure_installed

	return ensure_installed
end

return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"zapling/mason-conform.nvim",
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_conform = require("mason-conform")

		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
				border = "single",
				width = 0.8,
				height = 0.8,
			},
		})

		mason_lspconfig.setup({
			ensure_installed = ensure_lsp_installs(),
			automatic_installation = false,
		})

		mason_conform.setup({})
	end,
}
