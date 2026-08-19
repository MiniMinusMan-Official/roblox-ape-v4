local optionapi = {
	Type = 'Toggle',
	Enabled = false,
	Index = getTableSize(api.Options)
}
local toggle = Instance.new('TextButton')
toggle.Name = optionsettings.Name..'Toggle'
toggle.Size = UDim2.new(1, -12, 0, 42)
toggle.BackgroundTransparency = 1
toggle.BorderSizePixel = 0
toggle.AutoButtonColor = false
toggle.Visible = optionsettings.Visible == nil or optionsettings.Visible
toggle.Text = optionsettings.Name
toggle.TextXAlignment = Enum.TextXAlignment.Left
toggle.TextColor3 = uipallet.Text
toggle.TextSize = 18
toggle.FontFace = uipallet.Font
toggle.ZIndex = children.ZIndex + 1
toggle.Parent = children
local box = Instance.new('Frame')
box.Name = 'Box'
box.Size = UDim2.fromOffset(24, 24)
box.Position = UDim2.new(1, -32, 0.5, -12)
box.BackgroundColor3 = Color3.fromRGB(207, 207, 207)
box.BorderSizePixel = 0
box.ZIndex = toggle.ZIndex + 1
box.Parent = toggle
addCorner(box, UDim.new(1, 0))
local check = Instance.new('TextLabel')
check.Size = UDim2.fromScale(1, 1)
check.BackgroundTransparency = 1
check.Text = '✓'
check.TextColor3 = Color3.new(1, 1, 1)
check.TextSize = 18
check.FontFace = uipallet.FontSemiBold
check.Visible = false
check.ZIndex = box.ZIndex + 1
check.Parent = box
optionsettings.Function = optionsettings.Function or function() end
function optionapi:Save(tab)
	tab[optionsettings.Name] = {Enabled = self.Enabled}
end
function optionapi:Load(tab)
	if type(tab) == 'table' and self.Enabled ~= (tab.Enabled == true) then self:Toggle() end
end
function optionapi:Color(hue, sat, val)
	if self.Enabled then box.BackgroundColor3 = Color3.fromHSV(hue, sat, val) end
end
function optionapi:Toggle()
	self.Enabled = not self.Enabled
	box.BackgroundColor3 = self.Enabled and Color3.fromHSV(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value) or Color3.fromRGB(207, 207, 207)
	check.Visible = self.Enabled
	optionsettings.Function(self.Enabled)
end
toggle.MouseButton1Click:Connect(function() optionapi:Toggle() end)
if optionsettings.Default then optionapi:Toggle() end
optionapi.Object = toggle
api.Options[optionsettings.Name] = optionapi
return optionapi
