local optionapi = {
	Type = 'TextList',
	List = table.clone(optionsettings.Default or {}),
	ListEnabled = table.clone(optionsettings.Default or {}),
	Objects = {},
	Window = {Visible = false},
	Index = getTableSize(api.Options)
}
optionsettings.Function = optionsettings.Function or function() end
local button = Instance.new('TextButton')
button.Name = optionsettings.Name..'TextList'
button.Size = UDim2.new(1, -12, 0, 44)
button.BackgroundTransparency = 1
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Visible = optionsettings.Visible == nil or optionsettings.Visible
button.Text = optionsettings.Name
button.TextXAlignment = Enum.TextXAlignment.Left
button.TextColor3 = uipallet.Text
button.TextSize = 18
button.FontFace = uipallet.Font
button.ZIndex = children.ZIndex + 1
button.Parent = children
local count = Instance.new('TextLabel')
count.Size = UDim2.fromOffset(100, 44)
count.Position = UDim2.new(1, -125, 0, 0)
count.BackgroundTransparency = 1
count.TextXAlignment = Enum.TextXAlignment.Right
count.TextColor3 = uipallet.Muted
count.TextSize = 16
count.FontFace = uipallet.Font
count.ZIndex = button.ZIndex + 1
count.Parent = button
local arrow = count:Clone()
arrow.Size = UDim2.fromOffset(22, 44)
arrow.Position = UDim2.new(1, -22, 0, 0)
arrow.Text = '›'
arrow.TextSize = 25
arrow.Parent = button
local window = Instance.new('CanvasGroup')
window.Name = optionsettings.Name..'ListWindow'
window.Size = UDim2.fromOffset(420, 480)
window.Position = UDim2.fromScale(0.5, 0.5)
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
window.BorderSizePixel = 0
window.Visible = false
window.ZIndex = 60
window.Parent = modalBackdrop
addCorner(window, UDim.new(0, 10))
local title = Instance.new('TextLabel')
title.Size = UDim2.new(1, -54, 0, 55)
title.Position = UDim2.fromOffset(22, 7)
title.BackgroundTransparency = 1
title.Text = optionsettings.Name
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = uipallet.Text
title.TextSize = 29
title.FontFace = uipallet.Font
title.ZIndex = 61
title.Parent = window
local close = Instance.new('TextButton')
close.Size = UDim2.fromOffset(40, 40)
close.Position = UDim2.new(1, -48, 0, 10)
close.BackgroundTransparency = 1
close.Text = '×'
close.TextColor3 = uipallet.Muted
close.TextSize = 28
close.FontFace = uipallet.Font
close.ZIndex = 62
close.Parent = window
local input = Instance.new('TextBox')
input.Size = UDim2.new(1, -44, 0, 38)
input.Position = UDim2.fromOffset(22, 64)
input.BackgroundColor3 = Color3.fromRGB(243, 243, 243)
input.BorderSizePixel = 0
input.PlaceholderText = optionsettings.Placeholder or 'Add entry...'
input.PlaceholderColor3 = Color3.fromRGB(171, 171, 171)
input.Text = ''
input.TextColor3 = uipallet.Text
input.TextSize = 17
input.FontFace = uipallet.Font
input.ClearTextOnFocus = false
input.ZIndex = 61
input.Parent = window
addCorner(input, UDim.new(0, 4))
local list = Instance.new('ScrollingFrame')
list.Size = UDim2.new(1, -44, 1, -124)
list.Position = UDim2.fromOffset(22, 112)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 2
list.ScrollBarImageColor3 = uipallet.Accent
list.CanvasSize = UDim2.new()
list.ZIndex = 61
list.Parent = window
local layout = Instance.new('UIListLayout')
layout.Parent = list
layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
	list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
end)
optionapi.Window = window
local function refresh()
	for _, object in optionapi.Objects do object:Destroy() end
	table.clear(optionapi.Objects)
	count.Text = tostring(#optionapi.List)..' items'
	for _, name in optionapi.List do
		local row = Instance.new('TextButton')
		row.Name = name
		row.Size = UDim2.new(1, -6, 0, 39)
		row.BackgroundTransparency = 1
		row.Text = name
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.TextColor3 = uipallet.Text
		row.TextSize = 17
		row.FontFace = uipallet.Font
		row.ZIndex = 62
		row.Parent = list
		local enabled = Instance.new('Frame')
		enabled.Size = UDim2.fromOffset(18, 18)
		enabled.Position = UDim2.new(1, -57, 0.5, -9)
		enabled.BackgroundColor3 = table.find(optionapi.ListEnabled, name) and uipallet.Accent or Color3.fromRGB(207, 207, 207)
		enabled.BorderSizePixel = 0
		enabled.ZIndex = 63
		enabled.Parent = row
		addCorner(enabled, UDim.new(1, 0))
		local remove = Instance.new('TextButton')
		remove.Size = UDim2.fromOffset(28, 28)
		remove.Position = UDim2.new(1, -31, 0.5, -14)
		remove.BackgroundTransparency = 1
		remove.Text = '×'
		remove.TextColor3 = Color3.fromRGB(234, 104, 104)
		remove.TextSize = 21
		remove.FontFace = uipallet.Font
		remove.ZIndex = 63
		remove.Parent = row
		row.MouseButton1Click:Connect(function()
			local index = table.find(optionapi.ListEnabled, name)
			if index then table.remove(optionapi.ListEnabled, index) else table.insert(optionapi.ListEnabled, name) end
			optionsettings.Function()
			refresh()
		end)
		remove.MouseButton1Click:Connect(function()
			optionapi:ChangeValue(name)
		end)
		table.insert(optionapi.Objects, row)
	end
	list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
end
function optionapi:Save(tab) tab[optionsettings.Name] = {List = self.List, ListEnabled = self.ListEnabled} end
function optionapi:Load(tab)
	if type(tab) ~= 'table' then return end
	self.List = type(tab.List) == 'table' and tab.List or {}
	self.ListEnabled = type(tab.ListEnabled) == 'table' and tab.ListEnabled or {}
	refresh()
end
function optionapi:Color() end
function optionapi:ChangeValue(value)
	if value and value ~= '' then
		local index = table.find(self.List, value)
		if index then
			table.remove(self.List, index)
			local enabled = table.find(self.ListEnabled, value)
			if enabled then table.remove(self.ListEnabled, enabled) end
		else
			table.insert(self.List, value)
			table.insert(self.ListEnabled, value)
		end
	end
	optionsettings.Function(self.List)
	refresh()
end
input.FocusLost:Connect(function(enter)
	if enter and input.Text ~= '' then optionapi:ChangeValue(input.Text); input.Text = '' end
end)
button.MouseButton1Click:Connect(function() mainapi:ShowJelloModal(window) end)
close.MouseButton1Click:Connect(function() mainapi:HideJelloModal(window) end)
refresh()
optionapi.Object = button
api.Options[optionsettings.Name] = optionapi
return optionapi
