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

return M
