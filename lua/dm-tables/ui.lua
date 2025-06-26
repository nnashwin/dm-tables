local Popup = require("plenary.popup")

local M = {}

DMTablesId_win_id = nil

local function close_menu()
	print("close_menu()")
	vim.api.nvim_win_close(DMTablesId_win_id, true)

	DMTablesId_win_id = nil
end

local function create_window()
	local config = {}
	local width = config.width or 80
	local height = config.height or 40
	local borderchars = config.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	local bufnr = vim.api.nvim_create_buf(false, false)

	local DMTablesId_win_id, win = Popup.create(bufnr, {
		title = "DmTables",
		highlight = "TablesWindow",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
	})

	vim.api.nvim_win_set_option(win.border.win_id, "winhl", "Normal:TablesBorder")

	return {
		bufnr = bufnr,
		win_id = DMTablesId_win_id,
	}
end

function M.toggle_show_tables()
	--TODO replace with logger later
	print("toggle_show_tables()")
	if DMTablesId_win_id ~= nil and vim.api.nvim_win_is_valid(DMTablesId_win_id) then
		close_menu()
		return
	end

	local win_info = create_window()
	DMTablesId_win_id = win_info.win_id
end

return M
