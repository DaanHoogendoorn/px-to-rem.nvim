local M = {}

---@param path string
---@return string|nil
M.get_file_content = function(path)
	local file = io.open(path, "r")

	if not file then
		return nil
	end

	local content = file:read("*a")

	file:close()

	return content
end

return M
