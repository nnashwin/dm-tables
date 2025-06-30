local Popup = require("plenary.popup")
local data = require("dm-tables.data")
local log = require("dm-tables.dev").log

local M = {}

DMTablesId_win_id = nil
DMTablesId_buf = nil

local blocked_keys = {
	"i",
	"I",
	"a",
	"A",
	"o",
	"O",
	"c",
	"C",
	"s",
	"S",
	"r",
	"R",
	"dd",
	"D",
	"x",
	"X",
	"v",
	"V",
	"<C-a>",
	"<C-r>",
	"<C-v>",
	"p",
	"P",
	"u",
}

local function close_menu()
	log.trace("close_menu()")
	vim.api.nvim_buf_delete(DMTables_bufh, { force = true })

	DMTablesId_win_id = nil
	DMTables_bufh = nil
end

local function create_window()
	local config = {}
	local width = config.width or 80
	local height = config.height or 20
	local borderchars = config.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	local bufnr = vim.api.nvim_create_buf(false, false)

	local DMTablesId_win_id, win = Popup.create(bufnr, {
		title = "DmTables",
		highlight = "TablesWindow",
		line = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
	})

	vim.api.nvim_win_set_option(win.border.win_id, "winhl", "Normal:DMTablesBorder")

	return {
		bufnr = bufnr,
		win_id = DMTablesId_win_id,
	}
end

function M.toggle_show_tables()
	log.trace("toggle_show_tables()")
	if DMTablesId_win_id ~= nil and vim.api.nvim_win_is_valid(DMTablesId_win_id) then
		close_menu()
		return
	end

	local win_info = create_window()
	local contents = {}

	DMTablesId_win_id = win_info.win_id
	DMTables_bufh = win_info.bufnr

	contents = data.get_table_keys()

	if contents == nil or #contents == 0 then
		vim.notify(
			"There are currently no tables to display; please create a table and then run the command again",
			vim.log.levels.ERROR
		)
		return
	end

	--- Populate buffer with keys
	vim.api.nvim_win_set_option(DMTablesId_win_id, "number", true)
	vim.api.nvim_buf_set_name(DMTables_bufh, "dm-tables-menu")
	vim.api.nvim_buf_set_lines(DMTables_bufh, 0, #contents, false, contents)
	vim.api.nvim_buf_set_option(DMTables_bufh, "filetype", "dm-table-selection")
	vim.api.nvim_buf_set_option(DMTables_bufh, "buftype", "nofile")

	-- restrict keys from being used within the dmtables_buffer
	local buf_opts = { buffer = DMTables_bufh, noremap = true, silent = true }

	for _, key in ipairs(blocked_keys) do
		vim.keymap.set("n", key, "<Nop>", buf_opts)
	end

	vim.keymap.set("n", "r", function()
		log.trace("rename")
		local line_num = vim.api.nvim_win_get_cursor(0)[1]
		local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
		log.trace("line_text: ", line_text)
		local rename_text = vim.fn.input("New table name: ", line_text)

		if rename_text ~= line_text then
			data.update_table_key(line_text, rename_text)

			--re-render lines within the buffer after the operation was completed
			contents = data.get_table_keys()
			print("contents: ", contents)
			vim.api.nvim_buf_set_lines(DMTables_bufh, 0, #contents, true, contents)
			log.warn("contents: ", contents)
			print("contents: ", contents)
			return
		end
	end, buf_opts)

	vim.keymap.set("n", "dd", function()
		local line_num = vim.api.nvim_win_get_cursor(0)[1]
		local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

		local confirm_delete_table =
			vim.fn.input(string.format("Are you want to delete the table `%s`?\nType `y` to confirm: ", line_text))

		if confirm_delete_table == "y" then
			data.delete_table_by_key(line_text)

			--re-render lines within the buffer after the operation was completed
			contents = data.get_table_keys()
			vim.api.nvim_buf_set_lines(DMTables_bufh, line_num - 1, line_num, false, {})
			return
		end
	end, buf_opts)

	-- add allowed operations within the buffer
	vim.keymap.set("n", "<CR>", function()
		local line_num = vim.api.nvim_win_get_cursor(0)[1]
		local line_text = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]

		local dm_table = data.get_table_by_key(line_text)
		local random_idx = math.random(#dm_table)
		local random_element = dm_table[random_idx]

		vim.fn.setreg('"', random_element)

		close_menu()
		vim.notify(
			string.format(
				"Copied the random element `%s` from the dm-table `%s` to the clipboard",
				random_element,
				line_text
			),
			vim.log.levels.INFO
		)
	end, buf_opts)
end

return M
