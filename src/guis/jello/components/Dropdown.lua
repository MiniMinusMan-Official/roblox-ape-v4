local optionapi = {
	Type = 'Dropdown',
	Value = optionsettings.Default or optionsettings.List[1] or 'None',
	Index = getTableSize(api.Options)
}
optionsettings.Function = optionsettings.Function or function() end
local dropdown = Instance.new('Frame')
dropdown.Name = optionsettings.Name..'Dropdown'
dropdown.Size = UDim2.new(1, -12, 0, 40)
dropdown.BackgroundTransparency = 1
dropdown.BorderSizePixel = 0
dropdown.Visible = optionsettings.Visible == nil or optionsettings.Visible
dropdown.ZIndex = children.ZIndex + 1
dropdown.Parent = children
local button = Instance.new('TextButton')
button.Size = UDim2.fromScale(1, 1)
button.BackgroundTransparency = 1
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Text = optionsettings.Name
button.TextXAlignment = Enum.TextXAlignment.Left
button.TextColor3 = uipallet.Text
button.TextSize = 17
button.FontFace = uipallet.Font
button.ZIndex = dropdown.ZIndex + 1
button.Parent = dropdown
local value = Instance.new('TextLabel')
value.Size = UDim2.new(0.48, -28, 1, 0)
value.Position = UDim2.new(0.52, 0, 0, 0)
value.BackgroundTransparency = 1
value.Text = optionapi.Value
value.TextXAlignment = Enum.TextXAlignment.Right
value.TextColor3 = uipallet.Muted
value.TextSize = 15
value.TextTruncate = Enum.TextTruncate.AtEnd
value.FontFace = uipallet.Font
value.ZIndex = button.ZIndex + 1
value.Parent = button
local arrow = value:Clone()
arrow.Size = UDim2.fromOffset(22, 40)
arrow.Position = UDim2.new(1, -22, 0, 0)
arrow.Text = '›'
arrow.TextColor3 = Color3.fromRGB(113, 113, 113)
arrow.TextSize = 25
arrow.Parent = button
local choices
local function closeChoices()
	if choices then choices:Destroy(); choices = nil end
	dropdown.Size = UDim2.new(1, -12, 0, 40)
	arrow.Rotation = 0
end
function optionapi:Save(tab) tab[optionsettings.Name] = {Value = self.Value} end
function optionapi:Load(tab) if type(tab) == 'table' then self:SetValue(tab.Value) end end
function optionapi:Change(list)
	optionsettings.List = list or {}
	if not table.find(optionsettings.List, self.Value) then self:SetValue(optionsettings.List[1] or 'None') end
end
function optionapi:SetValue(selected, mouse)
	self.Value = table.find(optionsettings.List, selected) and selected or optionsettings.List[1] or 'None'
	value.Text = self.Value
	closeChoices()
	optionsettings.Function(self.Value, mouse)
end
button.MouseButton1Click:Connect(function()
	if choices then closeChoices(); return end
	choices = Instance.new('Frame')
	choices.Name = 'Choices'
	choices.Size = UDim2.new(1, 0, 0, math.max(#optionsettings.List * 36, 1))
	choices.Position = UDim2.fromOffset(0, 40)
	choices.BackgroundColor3 = Color3.fromRGB(248, 248, 248)
	choices.BorderSizePixel = 0
	choices.ZIndex = dropdown.ZIndex + 3
	choices.Parent = dropdown
	addCorner(choices, UDim.new(0, 5))
	local list = Instance.new('UIListLayout')
	list.Parent = choices
	for _, name in optionsettings.List do
		local choice = Instance.new('TextButton')
		choice.Name = name
		choice.Size = UDim2.new(1, 0, 0, 36)
		choice.BackgroundTransparency = 1
		choice.Text = name
		choice.TextColor3 = name == optionapi.Value and uipallet.Accent or uipallet.Text
	choice.TextSize = 16
		choice.FontFace = uipallet.Font
		choice.ZIndex = choices.ZIndex + 1
		choice.Parent = choices
		choice.MouseButton1Click:Connect(function() optionapi:SetValue(name, true) end)
	end
	dropdown.Size = UDim2.new(1, -12, 0, 40 + (#optionsettings.List * 36))
	arrow.Rotation = 90
end)
optionapi.Object = dropdown
api.Options[optionsettings.Name] = optionapi
return optionapi
