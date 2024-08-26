local M = {}

function M.deep_extend(t1, t2)
	local sections = {
		tabline_a = true,
		tabline_b = true,
		tabline_c = true,
		tab_active = true,
		tab_inactive = true,
		tabline_x = true,
		tabline_y = true,
		tabline_z = true,
		extensions = true,
	}

	for k, v in pairs(t2) do
		if sections[k] then
			t1[k] = v
		elseif type(v) == "table" then
			if type(t1[k] or false) == "table" then
				M.deep_extend(t1[k], t2[k])
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
	return t1
end

function M.insert_elements(dest, src)
	for _, v in ipairs(src) do
		table.insert(dest, v)
	end
end

local function require_component(window, v)
	local component
	if window.tab_id then
		component = "tabline.components.tab." .. v
	else
		component = "tabline.components.window." .. v
	end
	return component
end

function M.extract_components(components_opts, window)
	local components = {}
	for _, v in ipairs(components_opts) do
		if type(v) == "string" then
			if v == "ResetAttributes" then
				table.insert(components, v)
			elseif v == "Space" then
				table.insert(components, { Text = " " })
			else
				local ok, result = pcall(require, require_component(window, v))
				if ok then
					table.insert(components, { Text = result(window) .. "" })
				else
					table.insert(components, { Text = v .. "" })
				end
			end
		elseif type(v) == "table" and type(v[1]) == "string" then
			local ok, result = pcall(require, require_component(window, v[1]))
			if ok then
				if type(v.fmt) == "function" then
					table.insert(components, { Text = v.fmt(result(window), window) .. "" })
				else
					table.insert(components, { Text = result(window) .. "" })
				end
			end
		elseif type(v) == "function" then
			table.insert(components, { Text = v(window) .. "" })
		elseif type(v) == "table" then
			table.insert(components, v)
		end
	end
	return components
end

return M
