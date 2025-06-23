local Popup = require("plenary.popup")
local data = require("dm-tables.data")
local utils = require("dm-tables.utils")

local M = {}

-- Seed RNG and pop first few values
math.randomseed(os.time())
math.random()
math.random()
math.random()

local function create_window(force_save)
	local config = {}
	local width = config.width or 80
	local height = config.height or 50
	local borderchars = config.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	local bufnr = vim.api.nvim_create_buf(false, false)

	local Harpoon_win_id, win = Popup.create(bufnr, {
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
		win_id = Harpoon_win_id,
	}
end

local function has_content(lines)
	local has_content = false
	for _, line in ipairs(lines) do
		if line ~= "" then
			has_content = true
			break
		end
	end

	return has_content
end

vim.api.nvim_create_user_command("CreateTable", function()
	local lines = utils.get_visual_selection()
	local encoded_lines = vim.json.encode(utils.get_visual_selection())

	if not has_content(lines) then
		vim.notify("Selected text is empty; must select valid lines to create a table", vim.log.levels.ERROR)
		return
	end

	local dm_table_name = vim.fn.input("Name to use for this stored table: ")

	local db_data = vim.json.decode(data.read_from_db())

	if db_data[dm_table_name] ~= nil then
		vim.notify(
			string.format(
				"\nYou already have a table by the name of %s; Either delete the table or use a different name",
				dm_table_name
			),
			vim.log.levels.ERROR
		)
		return
	end

	db_data[dm_table_name] = encoded_lines

	data.write_to_db(vim.json.encode(db_data))
end, { range = true })

vim.keymap.set("v", "<leader>t", ":CreateTable<CR>")

return M
