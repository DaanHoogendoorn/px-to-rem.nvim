local px_to_rem = require("px-to-rem")

---Checks if a value is a px value
---@param value string
---@return boolean
local is_px_value = function(value)
	-- check if it's not a string first
	if type(value) ~= "string" then
		return false
	end

	return string.match(value, "^%d+%.?%d*[pP]?[xX]?$") ~= nil
end

--- @module 'blink.cmp'
--- @class blink.cmp.Source
local source = {}

function source.new()
	local self = setmetatable({}, { __index = source })
	return self
end

function source:enabled()
	return vim.tbl_contains(px_to_rem.options.filetypes, vim.bo.filetype)
end

function source:get_trigger_characters()
	return { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "." }
end

function source:get_completions(ctx, callback)
	local row, col = unpack(ctx.get_cursor())
	local line = ctx.get_line()
	local before_cursor = string.sub(line, 1, col)
	local value = string.match(before_cursor, "(%d*%.?%d*[pP]?[xX]?)$")

	if not is_px_value(value) then
		callback({ items = {}, is_incomplete_forward = true, is_incomplete_backward = true })
		return function() end
	end

	-- remove px from the value (if it's there or a part of it)
	local value_without_px = string.gsub(value, "[pP]?[xX]?$", "")

	local px_value = tonumber(value_without_px)
	if px_value == nil then
		callback({ items = {}, is_incomplete_forward = true, is_incomplete_backward = true })
		return function() end
	end

	local rem_value = px_to_rem.convert_to_rem(px_value)

	---@type blink.cmp.CompletionItem
	local completion_item = {
		label = string.format("%gpx   %grem", px_value, rem_value),
		kind = require("blink.cmp.types").CompletionItemKind.Value,
		-- insertText = rem_value .. "rem",
		textEdit = {
			newText = rem_value .. "rem",
			replace = {
				start = { line = row - 1, character = col - #value },
				["end"] = { line = row - 1, character = col },
			},
		},
		-- to make sure it's always the first item
		score = 99999,
		score_offset = 99999,
	}

	callback({
		items = {
			completion_item,
		},
		is_incomplete_forward = true,
		is_incomplete_backward = true,
	})
end

return source
