local M = {}

---@type boolean - Flag to ensure lazy_setup() only runs once
local initialized = false

local utils = require("px-to-rem.utils")

---@type PxToRemConfig
M.options = {
	root_font_size = 16,
	max_decimals = 3,
	filetypes = {
		"css",
		"scss",
		"sass",
		"less",
	},
	notify = true,
	integrations = {
		vscode_cipchk_cssrem = false,
	},
}

local lazy_setup = function()
	if initialized then
		return
	end

	-- Sets up the integration with the cssrem extension for VSCode
	if M.options.integrations.vscode_cipchk_cssrem then
		local vscode_integration = require("px-to-rem.integrations.vscode_cipchk_cssrem")

		local root_font_size = vscode_integration.get_root_font_size()
		if root_font_size ~= nil then
			M.options.root_font_size = root_font_size
		end

		local max_decimals = vscode_integration.get_max_decimals()
		if max_decimals ~= nil then
			M.options.max_decimals = max_decimals
		end
	end

	vim.api.nvim_create_user_command("PxToRemSetRootFontSize", function()
		local old_root_font_size = M.options.root_font_size

		local input = tonumber(vim.fn.input("Root font size: ", M.options.root_font_size))
		if input == nil then
			input = old_root_font_size
		end

		M.options.root_font_size = input
		M.notify("Root font size changed from " .. old_root_font_size .. " to " .. M.options.root_font_size)
	end, { desc = "Set the root font size" })

	vim.api.nvim_create_user_command("PxToRemSetDecimals", function()
		local old_max_decimals = M.options.max_decimals

		local input = tonumber(vim.fn.input("Max decimals: ", M.options.max_decimals))
		if input == nil then
			input = old_max_decimals
		end

		M.options.max_decimals = input

		M.notify("Max decimals changed from " .. old_max_decimals .. " to " .. M.options.max_decimals)
	end, { desc = "Set the maximum number of decimals" })

	vim.api.nvim_create_user_command(
		"PxToRemConvertAtCursor",
		M.convert_at_cursor,
		{ desc = "Convert the value at the cursor" }
	)
	vim.api.nvim_create_user_command(
		"PxToRemConvertAtLine",
		M.convert_at_line,
		{ desc = "Convert the values in the current line" }
	)
	vim.api.nvim_create_user_command(
		"PxToRemConvertBuffer",
		M.convert_at_buffer,
		{ desc = "Convert all px values in the current buffer" }
	)

	initialized = true
end

---Setup the plugin
---@param options PxToRemConfig|nil
M.setup = function(options)
	options = options or {}

	M.options = vim.tbl_deep_extend("force", M.options, options)

	for _, ft in ipairs(M.options.filetypes) do
		vim.api.nvim_create_autocmd("FileType", {
			pattern = ft,
			callback = lazy_setup,
			once = true,
		})
	end

	return M.options
end

---Converts a px value to rem
---@param px_value number
---@return number
M.convert_to_rem = function(px_value)
	local root_font_size = M.options.root_font_size
	local max_decimals = M.options.max_decimals

	local rem_value = px_value / root_font_size

	return utils.round_number(rem_value, max_decimals)
end

---Converts a rem value to px
---@param rem_value number
---@return number
M.convert_to_px = function(rem_value)
	local root_font_size = M.options.root_font_size
	---@type number
	local max_decimals = M.options.max_decimals

	local px_value = rem_value * root_font_size

	return utils.round_number(px_value, max_decimals)
end

---Converts a value from px to rem or rem to px or vice versa.
---@param value number
---@param unit string
---@return string|nil - The converted value, or nil if the conversion is invalid. Includes the unit in the returned string.
M.convert_to_string = function(value, unit)
	if unit == "rem" then
		return M.convert_to_rem(value) .. "rem"
	elseif unit == "px" then
		return M.convert_to_px(value) .. "px"
	end
end

---Converts the value at the cursor
M.convert_at_cursor = function()
	local input = vim.fn.expand("<cWORD>")
	local value = string.match(input, "%d*%.?%d*")
	local unit = string.match(input, "%a+")
	local rest_of_string = input.sub(input, string.len(value .. unit) + 1)

	local original_cursor = vim.api.nvim_win_get_cursor(0)

	if value == nil then
		M.notify("No px or rem value found")
		return
	end

	if unit == nil then
		unit = "px"
	end

	value = tonumber(value)

	if value == nil then
		M.notify("Invalid number")
		return
	end

	local target_unit = unit == "px" and "rem" or "px"

	local converted_value = M.convert_to_string(value, target_unit)

	if converted_value == nil then
		M.notify("Invalid unit")
		return
	end

	-- add rest of the original string if it's missing
	if rest_of_string ~= "" and rest_of_string ~= nil then
		converted_value = converted_value .. rest_of_string
	end

	vim.cmd("normal! ciW" .. converted_value)

	vim.api.nvim_win_set_cursor(0, original_cursor)
end

---Converts the values in the current line
---@param line number|nil - The line number to convert. If nil, the current line is used.
M.convert_line = function(line)
	line = line or vim.api.nvim_win_get_cursor(0)[1]
	local line_content = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1]
	local modified = false

	for match in line_content:gmatch("(-?%d+%.?%d*)px") do
		local value = tonumber(match)

		if value == nil then
			return
		end

		local converted_value = M.convert_to_string(value, "rem")

		if converted_value == nil then
			return
		end

		line_content = line_content:gsub(match .. "px", converted_value, 1)
		modified = true
	end

	if not modified then
		return nil
	end

	return line_content
end

M.convert_at_line = function()
	local line = vim.api.nvim_win_get_cursor(0)[1]
	local new_line_content = M.convert_line(line)
	vim.api.nvim_buf_set_lines(0, line - 1, line, false, { new_line_content })
end

M.convert_at_buffer = function()
	M.convert_buffer()
end

---Converts all px values in the current buffer
---@param bufnr number|nil - The buffer number to convert. If nil, the current buffer is used.
M.convert_buffer = function(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for line_number, line_content in ipairs(lines) do
		local converted_line = M.convert_line(line_number)
		if converted_line ~= nil then
			lines[line_number] = converted_line
		end
	end

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
end

M.notify = function(message)
	if not M.options.notify then
		return
	end

	vim.notify(message, vim.log.levels.INFO, {
		title = "px-to-rem.nvim",
	})
end

return M
