local M = {}

function M.get_visual_selection()
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	local start_line = start_pos[2]
	local end_line = end_pos[2]

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

	--handle the use case for when the user starts from the end of a table and visual copies to the top
	if end_pos[2] < start_pos[2] then
		lines = vim.api.nvim_buf_get_lines(0, end_line - 1, start_line, false)
	end

	return lines
end

return M
