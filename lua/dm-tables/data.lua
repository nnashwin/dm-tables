local M = {}

local function get_db_path()
	local data_dir = vim.fn.stdpath("data")
	local plugin_dir = data_dir .. "/dm-tables"

	vim.fn.mkdir(plugin_dir, "p")

	return plugin_dir .. "/tables.db"
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

---@return {}
function M.get_table_keys()
	local db_path = get_db_path()
	local file = io.open(db_path, "rb")

	if not file then
		return nil
	end

	local content = file:read("*a")

	local okay, content_table = pcall(vim.json.decode, content)
	if not okay then
		return nil
	end

	local keyset = {}
	local n = 0

	for k, _ in pairs(content_table) do
		n = n + 1
		keyset[n] = k
	end

	table.sort(keyset)

	file:close()

	return keyset
end

---@return nil
function M.delete_table_by_key(key)
	local db_path = get_db_path()
	local file = io.open(db_path, "r")

	if not file then
		return nil
	end

	local content = file:read("*a")

	file:close()

	local content_table = vim.json.decode(content)

	content_table[key] = nil

	local output_file = io.open(db_path, "w")

	if output_file then
		output_file:write(vim.json.encode(content_table))

		output_file:close()
	end
end

---@return {}
function M.get_table_by_key(key)
	local db_path = get_db_path()
	local file = io.open(db_path, "rb")

	if not file then
		return nil
	end

	local content = file:read("*a")

	local content_table = vim.json.decode(content)

	file:close()

	return vim.json.decode(content_table[key])
end

---@return nil
function M.update_table_key(original_table_key, new_table_key)
	local db_path = get_db_path()
	local file = io.open(db_path, "r")

	if not file then
		return nil
	end

	local content = file:read("*a")

	file:close()

	local content_table = vim.json.decode(content)

	local random_table_content = content_table[original_table_key]

	content_table[new_table_key] = random_table_content

	content_table[original_table_key] = nil

	local output_file = io.open(db_path, "w")

	if output_file then
		output_file:write(vim.json.encode(content_table))

		output_file:close()
	end
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

return M
