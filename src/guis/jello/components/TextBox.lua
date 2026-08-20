local optionapi = {Type = 'TextBox', Value = optionsettings.Default or '', Index = getTableSize(api.Options)}
optionsettings.Function = optionsettings.Function or function() end
local holder = Instance.new('Frame')
holder.Name = optionsettings.Name..'TextBox'
holder.Size = UDim2.new(1, -12, 0, 44)
holder.BackgroundTransparency = 1
holder.Visible = optionsettings.Visible == nil or optionsettings.Visible
holder.ZIndex = children.ZIndex + 1
holder.Parent = children
local title = Instance.new('TextLabel')
title.Size = UDim2.new(0.48, -8, 1, 0)
title.BackgroundTransparency = 1
title.Text = optionsettings.Name
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = uipallet.Text
title.TextSize = 17
title.FontFace = uipallet.Font
title.ZIndex = holder.ZIndex + 1
title.Parent = holder
local box = Instance.new('TextBox')
box.Size = UDim2.new(0.52, 0, 0, 30)
box.Position = UDim2.new(0.48, 0, 0.5, -15)
box.BackgroundColor3 = Color3.fromRGB(244, 244, 244)
box.BorderSizePixel = 0
box.Text = optionapi.Value
box.PlaceholderText = optionsettings.Placeholder or 'Click to set'
box.PlaceholderColor3 = Color3.fromRGB(170, 170, 170)
box.TextColor3 = uipallet.Text
box.TextXAlignment = Enum.TextXAlignment.Left
box.TextSize = 15
box.FontFace = uipallet.Font
box.ClearTextOnFocus = false
box.ZIndex = holder.ZIndex + 1
box.Parent = holder
addCorner(box, UDim.new(0, 4))
local padding = Instance.new('UIPadding')
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = box
function optionapi:Save(tab) tab[optionsettings.Name] = {Value = self.Value} end
function optionapi:Load(tab) if type(tab) == 'table' then self:SetValue(tab.Value or '') end end
function optionapi:SetValue(newValue, enter)
	self.Value = tostring(newValue or '')
	if box.Text ~= self.Value then box.Text = self.Value end
	optionsettings.Function(enter)
end
box.FocusLost:Connect(function(enter) optionapi:SetValue(box.Text, enter) end)
box:GetPropertyChangedSignal('Text'):Connect(function() optionapi.Value = box.Text end)
optionapi.Object = holder
api.Options[optionsettings.Name] = optionapi
return optionapi
