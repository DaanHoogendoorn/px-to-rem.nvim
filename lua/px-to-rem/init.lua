local M = {}

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
	integrations = {
		vscode_cipchk_cssrem = false,
	},
}

---Setup the plugin
---@param options PxToRemConfig|nil
M.setup = function(options)
	options = options or {}

	M.options = vim.tbl_deep_extend("force", M.options, options)

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
return M
