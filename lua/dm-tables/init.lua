local data = require("dm-tables.data")
local log = require("dm-tables.dev").log
local ui = require("dm-tables.ui")
local utils = require("dm-tables.utils")

local EMPTY_BUFFER_STRING = "EMPTY_BUFFER"

local M = {}

-- Seed RNG and pop first few values
math.randomseed(os.time())
math.random()
math.random()
math.random()

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

function M.create_table()
	local filename = vim.api.nvim_buf_get_name(0)
	if utils.is_string_empty(filename) then
		filename = EMPTY_BUFFER_STRING
	end

	local lines = utils.get_visual_selection()
	local encoded_lines = vim.json.encode(lines)

	if not has_content(lines) then
		vim.notify(
			"Selected text is empty; selection must contain no blank lines to create a table",
			vim.log.levels.ERROR
		)
		return
	end

	local dm_table_name = vim.fn.input("Name to use for this stored table: ")

	if dm_table_name == "" then
		vim.notify(
			string.format(
				"\nYou can not have a blank table name; create a unique name that fits your random table",
				dm_table_name
			),
			vim.log.levels.ERROR
		)
		return
	end

	local okay, db_data = pcall(vim.json.decode, data.read_from_db())
	if not okay then
		db_data = {}
	end

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
	local record = {}
	record["file_path"] = vim.api.nvim_buf_get_name(0)
	record["entries"] = encoded_lines

	db_data[dm_table_name] = record

	data.write_to_db(vim.json.encode(db_data))
end

function M.show_tables()
	log.trace("show_tables()")
	ui.toggle_show_tables()
end

return M
