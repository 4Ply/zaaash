return {
	--neodev
	{
		"folke/neodev.nvim",
	},
	-- lspconfig
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			"mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
	},
	--lsp servers
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		config = function()
			local lspconfig = require("lspconfig")
			local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
			local mason_lspconfig = require("mason-lspconfig")
			local border = {
				{ "╭", "FloatBorder" },
				{ "─", "FloatBorder" },
				{ "╮", "FloatBorder" },
				{ "│", "FloatBorder" },
				{ "╯", "FloatBorder" },
				{ "─", "FloatBorder" },
				{ "╰", "FloatBorder" },
				{ "│", "FloatBorder" },
			}
			local handlers = {
				vim.diagnostic.config({
					float = { border = "rounded" },
				}),
				["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
				["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
			}

			require("mason").setup({
				ui = { border = "rounded" },
				registries = {
					"github:nvim-java/mason-registry",
					"github:mason-org/mason-registry",
				},
			})
			mason_lspconfig.setup({
				ensure_installed = {
					"lua_ls",
					"pyright",
					"jdtls",
				},
			})
			--test

			mason_lspconfig.setup_handlers({
				function(server_name)
					lspconfig[server_name].setup({
						capabilities = lsp_capabilities,
						handlers = handlers,
					})
				end,
				["jdtls"] = function()
					require("java").setup()
					lspconfig.jdtls.setup({
						capabilities = lsp_capabilities,
						handlers = handlers,
					})
				end,
				["lua_ls"] = function()
					require("neodev").setup({
						library = { plugins = { "neotest" }, types = true },
					})
					lspconfig.lua_ls.setup({
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim" },
								},
							},
						},
					})
				end,
			})
		end,
	},
	--lsp diagnostics
	{
		"folke/trouble.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
	--lsp garbage collection
	{
		"zeioth/garbage-day.nvim",
		event = "BufEnter",
		opts = {
			notifications = true,
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		opts = {
			ensure_installed = {
				"black",
				"usort",
				"prettier",
				"prettierd",
				"shfmt",
				"checkstyle",
				"jq",
				"yamlfmt",
			},
		},
	},
}