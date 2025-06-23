local M = {}

local function get_db_path()
	local data_dir = vim.fn.stdpath("data")
	local plugin_dir = data_dir .. "/dm-tables"

	vim.fn.mkdir(plugin_dir, "p")

	return plugin_dir .. "/tables.db"
end

---@return nil
function M.write_to_db(text)
	local db_path = get_db_path()
	local file = io.open(db_path, "wb")

	if file then
		file:write(text)

		file:close()
	end
end

---@return string
function M.read_from_db()
	local db_path = get_db_path()
	local file = io.open(db_path, "rb")

	if not file then
		return ""
	end

	local content = file:read("*a")
	file:close()

	return content
end

return M
