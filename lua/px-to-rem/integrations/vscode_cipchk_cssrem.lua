local M = {}

local utils = require("px-to-rem.utils")

local get_vscode_settings_file_path = function()
	local working_directory = vim.fn.getcwd()
	local vscode_settings_file = working_directory .. "/.vscode/settings.json"

	return vscode_settings_file
end

local get_vscode_settings = function()
	-- check if file exists
	if not vim.fn.filereadable(get_vscode_settings_file_path()) then
		return nil
	end

	local file = utils.get_file_content(get_vscode_settings_file_path())

	if not file or #file == 0 then
		return nil
	end

	local settings = vim.fn.json_decode(file)

	return settings
end

---Gets a setting from the vscode settings file
---@param key string
---@return unknown
local get_vscode_setting = function(key)
	local settings = get_vscode_settings()

	if settings == nil then
		return nil
	end

	return settings[key]
end

local get_cssrem_settings_file_path = function()
	local working_directory = vim.fn.getcwd()
	local cssrem_settings_file = working_directory .. "/.cssrem"

	return cssrem_settings_file
end

local get_cssrem_settings = function()
	-- check if file exists
	if not vim.fn.filereadable(get_cssrem_settings_file_path()) then
		return nil
	end

	local file = utils.get_file_content(get_cssrem_settings_file_path())

	if not file or #file == 0 then
		return nil
	end

	local settings = vim.fn.json_decode(file)

	return settings
end

---Gets a setting from the cssrem settings file
---@param key string
---@return unknown
local get_cssrem_setting = function(key)
	local settings = get_cssrem_settings()

	if settings == nil then
		return nil
	end

	return settings[key]
end

---Gets the root font size
---@return number|nil
M.get_root_font_size = function()
	local root_font_size = get_cssrem_setting("rootFontSize")

	if root_font_size == nil then
		root_font_size = get_vscode_setting("cssrem.rootFontSize")
		if root_font_size == nil then
			return nil
		end
	end

	return tonumber(root_font_size)
end

---Gets the maximum number of decimals to round to
---@return number|nil
M.get_max_decimals = function()
	local max_decimals = get_cssrem_setting("fixedDigits")

	if max_decimals == nil then
		max_decimals = get_vscode_setting("cssrem.fixedDigits")
		if max_decimals == nil then
			return nil
		end
	end

	return tonumber(max_decimals)
end

return M
