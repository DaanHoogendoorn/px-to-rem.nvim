local M = {}

---@param number number
---@param decimals number
---@return number
M.round_number = function(number, decimals)
	local factor = 10 ^ decimals

	return math.floor(number * factor + 0.5) / factor
end

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
