local optionapi = {
	Type = 'Slider',
	Value = optionsettings.Default or optionsettings.Min,
	Max = optionsettings.Max,
	Index = getTableSize(api.Options)
}
optionsettings.Decimal = optionsettings.Decimal or 1
optionsettings.Function = optionsettings.Function or function() end
local slider = Instance.new('TextButton')
slider.Name = optionsettings.Name..'Slider'
slider.Size = UDim2.new(1, -12, 0, 50)
slider.BackgroundTransparency = 1
slider.BorderSizePixel = 0
slider.AutoButtonColor = false
slider.Visible = optionsettings.Visible == nil or optionsettings.Visible
slider.Text = ''
slider.ZIndex = children.ZIndex + 1
slider.Parent = children
local title = Instance.new('TextLabel')
title.Size = UDim2.new(0.5, -8, 1, 0)
title.BackgroundTransparency = 1
title.Text = optionsettings.Name
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = uipallet.Text
title.TextSize = 17
title.FontFace = uipallet.Font
title.ZIndex = slider.ZIndex + 1
title.Parent = slider
local valuebox = Instance.new('TextBox')
valuebox.Size = UDim2.new(0.5, -8, 0, 24)
valuebox.Position = UDim2.new(0.5, 0, 0, 1)
valuebox.BackgroundTransparency = 1
valuebox.TextXAlignment = Enum.TextXAlignment.Right
valuebox.TextColor3 = uipallet.Muted
valuebox.TextSize = 15
valuebox.FontFace = uipallet.Font
valuebox.ClearTextOnFocus = false
valuebox.ZIndex = title.ZIndex
valuebox.Parent = slider
local track = Instance.new('Frame')
track.Name = 'Track'
track.Size = UDim2.new(0.46, -8, 0, 5)
track.Position = UDim2.new(0.54, 4, 0, 34)
track.BackgroundColor3 = Color3.fromRGB(222, 229, 236)
track.BorderSizePixel = 0
track.ZIndex = slider.ZIndex + 1
track.Parent = slider
addCorner(track, UDim.new(1, 0))
local fill = Instance.new('Frame')
fill.Name = 'Fill'
fill.Size = UDim2.new()
fill.BackgroundColor3 = uipallet.Accent
fill.BorderSizePixel = 0
fill.ZIndex = track.ZIndex + 1
fill.Parent = track
addCorner(fill, UDim.new(1, 0))
local knob = Instance.new('Frame')
knob.Name = 'Knob'
knob.Size = UDim2.fromOffset(12, 12)
knob.Position = UDim2.new(1, -6, 0.5, -6)
knob.BackgroundColor3 = uipallet.Accent
knob.BorderSizePixel = 0
knob.ZIndex = fill.ZIndex + 1
knob.Parent = fill
addCorner(knob, UDim.new(1, 0))
local function scaleFor(value)
	local range = optionsettings.Max - optionsettings.Min
	return range == 0 and 0 or math.clamp((value - optionsettings.Min) / range, 0, 1)
end
local function displayValue(value)
	local suffix = optionsettings.Suffix and (type(optionsettings.Suffix) == 'function' and optionsettings.Suffix(value) or optionsettings.Suffix) or ''
	return tostring(value)..(suffix ~= '' and ' '..suffix or '')
end
function optionapi:Save(tab) tab[optionsettings.Name] = {Value = self.Value} end
function optionapi:Load(tab) if type(tab) == 'table' then self:SetValue(tab.Value) end end
function optionapi:Color(hue, sat, val)
	fill.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
	knob.BackgroundColor3 = fill.BackgroundColor3
end
function optionapi:SetValue(value, mouse, final, silent)
	value = tonumber(value)
	if not value or value ~= value or value == math.huge or value == -math.huge then return end
	value = math.clamp(value, optionsettings.Min, optionsettings.Max)
	value = math.floor(value * optionsettings.Decimal) / optionsettings.Decimal
	local changed = self.Value ~= value
	self.Value = value
	valuebox.Text = displayValue(value)
	fill.Size = UDim2.fromScale(scaleFor(value), 1)
	if not silent and (changed or final) then optionsettings.Function(value, final) end
end
local function setFromInput(input, final)
	local scaleValue = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
	optionapi:SetValue(optionsettings.Min + ((optionsettings.Max - optionsettings.Min) * scaleValue), true, final)
end
slider.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	if input.Position.Y - track.AbsolutePosition.Y < -12 then return end
	setFromInput(input, false)
	local changed
	changed = inputService.InputChanged:Connect(function(move)
		if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then setFromInput(move, false) end
	end)
	local ended
	ended = input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			if changed then changed:Disconnect() end
			if ended then ended:Disconnect() end
			optionsettings.Function(optionapi.Value, true)
		end
	end)
end)
valuebox.FocusLost:Connect(function(enter)
	if enter then optionapi:SetValue(valuebox.Text:match('[-%d%.]+'), true, true) else valuebox.Text = displayValue(optionapi.Value) end
end)
optionapi:SetValue(optionapi.Value, nil, nil, true)
optionapi.Object = slider
api.Options[optionsettings.Name] = optionapi
return optionapi
