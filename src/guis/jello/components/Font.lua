local fonts = {optionsettings.Blacklist, 'Custom'}
for _, font in Enum.Font:GetEnumItems() do
	if not table.find(fonts, font.Name) then table.insert(fonts, font.Name) end
end
local optionapi = {Value = Font.fromEnum(Enum.Font[fonts[1]])}
optionsettings.Function = optionsettings.Function or function() end
local fontbox
local dropdown
dropdown = components.Dropdown({
	Name = optionsettings.Name,
	List = fonts,
	Visible = optionsettings.Visible,
	Function = function(value)
		fontbox.Object.Visible = value == 'Custom' and dropdown.Object.Visible
		if value ~= 'Custom' then
			optionapi.Value = Font.fromEnum(Enum.Font[value])
		else
			pcall(function() optionapi.Value = Font.fromId(tonumber(fontbox.Value)) end)
		end
		optionsettings.Function(optionapi.Value)
	end
}, children, api)
fontbox = components.TextBox({
	Name = optionsettings.Name..' Asset',
	Placeholder = 'Font asset ID',
	Visible = false,
	Function = function()
		if dropdown.Value == 'Custom' then
			pcall(function() optionapi.Value = Font.fromId(tonumber(fontbox.Value)) end)
			optionsettings.Function(optionapi.Value)
		end
	end
}, children, api)
dropdown.Object:GetPropertyChangedSignal('Visible'):Connect(function()
	fontbox.Object.Visible = dropdown.Object.Visible and dropdown.Value == 'Custom'
end)
optionapi.Object = dropdown.Object
return optionapi
