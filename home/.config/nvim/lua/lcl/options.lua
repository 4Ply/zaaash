M = {}

local position_tracker = {
	last_good_pos = nil,
	is_restoring = false,
}

-- Track position continuously
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	group = vim.api.nvim_create_augroup("PositionTracker", { clear = true }),
	callback = function()
		if not position_tracker.is_restoring then
			position_tracker.last_good_pos = vim.api.nvim_win_get_cursor(0)
		end
	end,
})

-- Position restoration
local function restore_position()
	if position_tracker.last_good_pos and not position_tracker.is_restoring then
		position_tracker.is_restoring = true
		vim.api.nvim_win_set_cursor(0, position_tracker.last_good_pos)
		position_tracker.is_restoring = false
	end
end

vim.api.nvim_create_autocmd({ "VimResized", "FocusGained", "FocusLost" }, {
	group = vim.api.nvim_create_augroup("CursorStabilize", { clear = true }),
	callback = function()
		vim.defer_fn(restore_position, 0)
	end,
})

return M
