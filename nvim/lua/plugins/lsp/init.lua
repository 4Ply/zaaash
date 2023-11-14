return {
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
		keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		dependencies = {
			{ "mfussenegger/nvim-jdtls" },
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					-- Replace these with whatever servers you want to install
					"lua_ls",
				},
			})

			local lspconfig = require("lspconfig")
			local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

			local function lsp_keymap(bufnr)
				local bufopts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
				vim.keymap.set("n", "<leader>K", vim.lsp.buf.signature_help, bufopts)
				vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
				vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, bufopts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
				vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
				vim.keymap.set("n", "<leader>lf", vim.lsp.buf.formatting, bufopts)
			end

			local lsp_attach = function(client, bufnr)
				lsp_keymap(bufnr)
			end

			require("mason-lspconfig").setup_handlers({
				function(server_name)
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
						["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
						["textDocument/signatureHelp"] = vim.lsp.with(
							vim.lsp.handlers.signature_help,
							{ border = border }
						),
					}

					if server_name == "lua_ls" then
						lspconfig[server_name].setup({
							on_attach = lsp_attach,
							capabilities = lsp_capabilities,
							handlers = handlers,
							settings = {
								Lua = {
									diagnostics = {
										globals = { "vim" },
									},
								},
							},
						})
					else
						lspconfig[server_name].setup({
							on_attach = lsp_attach,
							capabilities = lsp_capabilities,
							handlers = handlers,
						})
					end
				end,
				["jdtls"] = function() end,
			})
		end,
	},
	--lsp diagnostics
	{
		"folke/trouble.nvim",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	--lsp garbage collection
	{
		"zeioth/garbage-day.nvim",
		event = "BufEnter",
		opts = {
			-- your options here
		},
	},
}
