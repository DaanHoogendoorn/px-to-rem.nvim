local M = {}

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
}

---Setup the plugin
---@param options PxToRemConfig|nil
M.setup = function(options)
	options = options or {}

	M.options = vim.tbl_deep_extend("force", M.options, options)
end

return M
