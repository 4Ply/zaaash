local P = require("user.utils").PREFIXES

local mappings = {
	{
		"BufEnter",
		function()
			if vim.g.workspaces_loaded then
				require("workspaces.marks").clear_marks()
				require("workspaces.marks").display_marks()
			end
		end,
		prefix = P.auto,
	},
	{
		"BufEnter",
		opts = {
			pattern = { "*.zsh-theme", "*.zshrc", "*.zshenv", "*.zprofile" },
		},
		function()
			vim.cmd("setfiletype zsh")
		end,
		prefix = P.auto,
	},
	{
		"BufWritePost",
		function()
			vim.schedule(function()
				vim.cmd("nohlsearch")
			end)
		end,
		prefix = P.auto,
	},
	{
		"WinClosed",
		function()
			if vim.g.backdrop_buf then
				require("user.utils").close_backdrop_window()
			end
		end,
		prefix = P.auto,
	},
	{
		"FileType",
		opts = {
			pattern = "markdown",
		},
		function()
			vim.opt.wrap = false
		end,
		prefix = P.auto,
	},
	{
		"BufWritePost",
		opts = {
			pattern = "*.bib",
		},
		function()
			vim.cmd("!bibtex main")
		end,
		prefix = P.auto,
	},
	{
		"BufWinEnter",
		function()
			if vim.bo.bt == "terminal" then
				vim.opt_local.number = false
				vim.opt_local.relativenumber = false
			end
			if vim.bo.ft == "help" then
				vim.cmd("wincmd L")
			end
		end,
		prefix = P.auto,
	},
	{
		"TermOpen",
		function()
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
		end,
		prefix = P.auto,
	},
	{
		"QuitPre",
		function()
			local terms = require("toggleterm.terminal").get_all()
			for _, term in ipairs(terms) do
				if vim.fn.win_id2win(term.window) == vim.fn.winnr() then
					local session_terms = require("workspaces.toggleterms").get_session_terms()
					for _, value in ipairs(session_terms) do
						if value.global_id == term.id then
							require("workspaces.toggleterms").delete_term(value.local_id)
						end
					end
				end
			end
		end,
		prefix = P.auto,
	},
	{
		name = "UserTelescope",
		{
			"User",
			opts = {
				pattern = { "TelescopeFindPre" },
			},
			function()
				if not vim.g.backdrop_buf then
					require("user.utils").create_backdrop_window()
				end
			end,
		},
	},
	{
		name = "UserMiniFiles",
		{
			"User",
			opts = {
				pattern = "MiniFilesWindowOpen",
			},
			function(args)
				if not vim.g.backdrop_buf then
					require("user.utils").create_backdrop_window()
				end
				local win_id = args.data.win_id
				vim.api.nvim_win_set_config(win_id, { border = "rounded" })
			end,
			prefix = P.auto,
		},
		{
			"User",
			opts = {
				pattern = "MiniFilesBufferCreate",
			},
			function(args)
				local MiniFiles = require("mini.files")
				local buf_id = args.data.buf_id
				vim.keymap.set("n", "h", function()
					MiniFiles.go_out()
					MiniFiles.go_out()
					MiniFiles.go_in({})
				end, { buffer = buf_id })

				vim.keymap.set("n", "<esc>", function()
					MiniFiles.close()
				end, { buffer = buf_id })

				vim.keymap.set("n", "<CR>", function()
					MiniFiles.go_in({ close_on_file = true })
				end, { buffer = buf_id })

				vim.keymap.set("n", "<leader>scs", function()
					local fs_entry = MiniFiles.get_fs_entry()

					if not fs_entry then
						vim.notify("Cannot identify filesystem entry")
						return
					end

					if fs_entry.fs_type == "directory" then
						MiniFiles.close()
						require("workspaces.workspaces").create_session(fs_entry.name, fs_entry.path)
					else
						MiniFiles.close()
						vim.notify("File selected, creating session from parent directory")
						local split_path = vim.split(fs_entry.path, "/")
						table.remove(split_path)
						local new_path = table.concat(split_path, "/")
						require("workspaces.workspaces").create_session(fs_entry.name, new_path)
					end
				end, { buffer = buf_id })

				vim.keymap.set("n", "<leader>scw", function()
					local fs_entry = MiniFiles.get_fs_entry()

					if not fs_entry then
						vim.notify("Cannot identify filesystem entry")
						return
					end

					if fs_entry.fs_type == "directory" then
						MiniFiles.close()
						require("workspaces.workspaces").create_workspace(fs_entry.name, fs_entry.name, fs_entry.path)
						vim.notify("Workspace created")
					else
						MiniFiles.close()
						vim.notify("File selected, creating workspace from parent directory")
						local split_path = vim.split(fs_entry.path, "/")
						table.remove(split_path)
						local new_path = table.concat(split_path, "/")
						require("workspaces.workspaces").create_workspace(fs_entry.name, fs_entry.name, new_path)
						vim.notify("Workspace created")
					end
				end, { buffer = buf_id })
			end,
			prefix = P.auto,
		},
	},
	{
		"QuickFixCmdPost",
		function()
			require("trouble").open("qflist")
		end,
		prefix = P.auto,
	},
	{
		"User",
		opts = {
			pattern = "LazyReload",
		},
		function()
			if vim.g.workspaces_loaded then
				require("workspaces.workspaces").setup_lualine()
			end
		end,
		prefix = P.auto,
	},
	{
		"VimLeave",
		function()
			if vim.g.workspaces_loaded then
				local state = require("workspaces.state")
				local persist = require("workspaces.persistence")
				local workspaces = require("workspaces.workspaces")
				local current_session = state.get().current_session
				persist.write_nvim_session_file(state.get().current_workspace, current_session)
				local toggled_types = require("user.utils").toggle_special_buffers({})
				workspaces.set_session_metadata(current_session, toggled_types)
				persist.persist_workspaces()
			end
		end,
		prefix = P.auto,
	},
}

return {
	setup = function()
		local prefixifier = require("user.utils").prefixifier
		local autocmds = require("legendary").autocmds
		prefixifier(autocmds)(mappings)
	end,
}
