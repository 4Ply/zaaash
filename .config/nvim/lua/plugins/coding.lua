return {
	--git
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text_pos = "right_align",
				delay = 500,
			},
		},
	},
	{
		"rhysd/git-messenger.vim",
		event = "VeryLazy",
		init = function()
			vim.cmd([[ let g:git_messenger_floating_win_opts = { "border":"rounded" } ]])
			vim.cmd([[ let g:git_messenger_always_into_popup = v:true ]])
		end,
	},
	--treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = { "lua", "python", "java", "javascript", "html" },
				auto_install = true,
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
	--auto close brackets
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter", "CmdlineEnter" },
		branch = "v0.6",
		opts = {
			bs = {
				enable = false,
			},
		},
	},
	--cmp
	{
		"hrsh7th/nvim-cmp",
		version = false, -- last release is way too old
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-calc",
			"onsails/lspkind.nvim",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function()
			local luasnip = require("luasnip")
			local lspkind = require("lspkind")
			local cmp = require("cmp")
			local window_scroll_bordered = cmp.config.window.bordered({
				scrolloff = 3,
				scrollbar = true,
			})

			local function tab(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end

			local function shift_tab(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = {
					["<Tab>"] = cmp.mapping(tab, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(shift_tab, { "i", "s" }),
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.close(),
					["<CR>"] = cmp.mapping.confirm({
						select = false,
					}),
				},
				window = {
					documentation = window_scroll_bordered,
					completion = window_scroll_bordered,
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp", max_item_count = 5 },
					{ name = "luasnip", max_item_count = 8 },
					{ name = "codeium" },
					{ name = "calc" },
					{ name = "nvim_lsp_signature_help" },
				}, {
					{ name = "buffer" },
				}),
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(entry, vim_item)
						local kind = lspkind.cmp_format({
							mode = "symbol_text",
							maxwidth = 50,
							symbol_map = { Codeium = "" },
						})(entry, vim_item)
						local strings = vim.split(kind.kind, "%s", { trimempty = true })
						kind.kind = " " .. (strings[1] or "") .. " "
						kind.menu = "    (" .. (strings[2] or "") .. ")"
						return kind
					end,
				},
			})
			-- `/` cmdline setup.
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
			-- `:` cmdline setup.
			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})
		end,
	},

	--snippets
	{
		"mireq/luasnip-snippets",
		dependencies = { "L3MON4D3/LuaSnip" },
		init = function()
			require("luasnip_snippets.common.snip_utils").setup()
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"nvim-treesitter/nvim-treesitter",
			init = function()
				local ls = require("luasnip")
				ls.setup({
					load_ft_func = require("luasnip_snippets.common.snip_utils").load_ft_func,
					ft_func = require("luasnip_snippets.common.snip_utils").ft_func,
					enable_autosnippets = true,
					history = true,
					updateevents = "TextChanged,TextChangedI",
				})
				require("luasnip/loaders/from_vscode").lazy_load()
			end,
		},
	},
	--better commenting
	{
		"numToStr/Comment.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
	},
	--function overview
	{
		"stevearc/aerial.nvim",
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		event = "VeryLazy",
		opts = {
			backends = { "lsp", "treesitter", "markdown", "man" },
			filter_kind = {
				"Array",
				"Class",
				"Constant",
				"Constructor",
				"Enum",
				"Field",
				"File",
				"Function",
				"Interface",
				"Method",
				"Module",
				"Namespace",
				"Null",
				-- "Object",
				"Package",
				"Struct",
				"TypeParameter",
			},
			layout = {
				min_width = 20,
			},
		},
	},
	--autoformat
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = false })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		-- Everything in opts will be passed to setup()
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "usort", "black" },
				java = { "checkstyle" },
				javascript = { { "prettierd", "prettier" } },
				javascriptreact = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },
				json = { "jq" },
				go = { "gofumpt" },
				bash = { "shfmt" },
				sh = { "shfmt" },
				zsh = { "shfmt" },
				yml = { "yamlfmt" },
				yaml = { "yamlfmt" },
			},
			format_on_save = function(bufnr)
				local ignore_filetypes = { "lua" }
				if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
					return { timeout_ms = 500, lsp_fallback = true }
				end
				local lines = vim.fn.system("git diff --unified=0 " .. vim.fn.bufname(bufnr)):gmatch("[^\n\r]+")
				local ranges = {}
				for line in lines do
					if line:find("^@@") then
						local line_nums = line:match("%+.- ")
						if line_nums:find(",") then
							local _, _, first, second = line_nums:find("(%d+),(%d+)")
							table.insert(ranges, {
								start = { tonumber(first), 0 },
								["end"] = { tonumber(first) + tonumber(second), 0 },
							})
						else
							local first = tonumber(line_nums:match("%d+"))
							table.insert(ranges, {
								start = { first, 0 },
								["end"] = { first + 1, 0 },
							})
						end
					end
				end
				local format = require("conform").format
				for _, range in pairs(ranges) do
					format({ range = range })
				end
			end,
			-- Customize formatters
			formatters = {
				prettier = {
					prepend_args = { "--tab-width", "4" },
				},
				shfmt = {
					prepend_args = { "-i", "2" },
				},
			},
		},
		init = function()
			-- If you want the formatexpr, here is the place to set it
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
	--latex
	{
		"lervag/vimtex",
		ft = { "markdown", "tex" },
		init = function()
			vim.g.vimtex_syntax_enabled = 1
			vim.g.vimtex_compiler_latexmk = {
				build_dir = function()
					return vim.fn["vimtex#util#find_root"]()
				end,
				callback = 1,
				continuous = 1,
				executable = "latexmk",
				hooks = {},
				options = {
					"-xelatex",
					"-shell-escape",
					"-verbose",
					"-file-line-error",
					"-synctex=1",
					"-interaction=nonstopmode",
				},
			}
			vim.g.vimtex_view_method = "zathura"
			vim.g.vimtex_quickfix_enabled = 0
		end,
	},
}