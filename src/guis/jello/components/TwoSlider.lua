local optionapi = {
	Type = 'TwoSlider',
	ValueMin = optionsettings.DefaultMin or optionsettings.Min,
	ValueMax = optionsettings.DefaultMax or optionsettings.Max,
	Max = optionsettings.Max,
	Index = getTableSize(api.Options)
}
optionsettings.Decimal = optionsettings.Decimal or 1
optionsettings.Function = optionsettings.Function or function() end
local slider = Instance.new('TextButton')
slider.Name = optionsettings.Name..'TwoSlider'
slider.Size = UDim2.new(1, -12, 0, 64)
slider.BackgroundTransparency = 1
slider.BorderSizePixel = 0
slider.AutoButtonColor = false
slider.Visible = optionsettings.Visible == nil or optionsettings.Visible
slider.Text = ''
slider.ZIndex = children.ZIndex + 1
slider.Parent = children
local title = Instance.new('TextLabel')
title.Size = UDim2.new(0.6, 0, 0, 31)
title.BackgroundTransparency = 1
title.Text = optionsettings.Name
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = uipallet.Text
title.TextSize = 18
title.FontFace = uipallet.Font
title.ZIndex = slider.ZIndex + 1
title.Parent = slider
local values = title:Clone()
values.Size = UDim2.new(0.4, 0, 0, 31)
values.Position = UDim2.fromScale(0.6, 0)
values.TextXAlignment = Enum.TextXAlignment.Right
values.TextColor3 = uipallet.Muted
values.TextSize = 16
values.Parent = slider
local track = Instance.new('Frame')
track.Size = UDim2.new(1, -8, 0, 7)
track.Position = UDim2.fromOffset(4, 44)
track.BackgroundColor3 = Color3.fromRGB(222, 229, 236)
track.BorderSizePixel = 0
track.ZIndex = slider.ZIndex + 1
track.Parent = slider
addCorner(track, UDim.new(1, 0))
local fill = Instance.new('Frame')
fill.Name = 'Fill'
fill.BackgroundColor3 = uipallet.Accent
fill.BorderSizePixel = 0
fill.ZIndex = track.ZIndex + 1
fill.Parent = track
addCorner(fill, UDim.new(1, 0))
local minKnob = Instance.new('Frame')
minKnob.Size = UDim2.fromOffset(14, 14)
minKnob.Position = UDim2.fromOffset(-7, -4)
minKnob.BackgroundColor3 = uipallet.Accent
minKnob.BorderSizePixel = 0
minKnob.ZIndex = fill.ZIndex + 1
minKnob.Parent = fill
addCorner(minKnob, UDim.new(1, 0))
local maxKnob = minKnob:Clone()
maxKnob.Position = UDim2.new(1, -7, 0, -4)
maxKnob.Parent = fill
local function position(value)
	local range = optionsettings.Max - optionsettings.Min
	return range == 0 and 0 or math.clamp((value - optionsettings.Min) / range, 0, 1)
end
local function refresh()
	local low, high = position(optionapi.ValueMin), position(optionapi.ValueMax)
	fill.Position = UDim2.fromScale(low, 0)
	fill.Size = UDim2.fromScale(math.max(high - low, 0), 1)
	values.Text = tostring(optionapi.ValueMin)..'  —  '..tostring(optionapi.ValueMax)
end
function optionapi:Save(tab) tab[optionsettings.Name] = {ValueMin = self.ValueMin, ValueMax = self.ValueMax} end
function optionapi:Load(tab)
	if type(tab) == 'table' then self:SetValue(false, tab.ValueMin); self:SetValue(true, tab.ValueMax) end
end
function optionapi:Color(hue, sat, val)
	fill.BackgroundColor3 = Color3.fromHSV(hue, sat, val)
	minKnob.BackgroundColor3 = fill.BackgroundColor3
	maxKnob.BackgroundColor3 = fill.BackgroundColor3
end
function optionapi:GetRandomValue() return Random.new():NextNumber(self.ValueMin, self.ValueMax) end
function optionapi:SetValue(maximum, value)
	value = tonumber(value)
	if not value or value ~= value then return end
	value = math.floor(math.clamp(value, optionsettings.Min, optionsettings.Max) * optionsettings.Decimal) / optionsettings.Decimal
	if maximum then self.ValueMax = math.max(value, self.ValueMin) else self.ValueMin = math.min(value, self.ValueMax) end
	refresh()
	optionsettings.Function(self.ValueMin, self.ValueMax)
end
slider.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	if input.Position.Y - track.AbsolutePosition.Y < -12 then return end
	local maximum = math.abs(input.Position.X - maxKnob.AbsolutePosition.X) <= math.abs(input.Position.X - minKnob.AbsolutePosition.X)
	local function update(move)
		local valueScale = math.clamp((move.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		optionapi:SetValue(maximum, optionsettings.Min + ((optionsettings.Max - optionsettings.Min) * valueScale))
	end
	update(input)
	local changed
	changed = inputService.InputChanged:Connect(function(move)
		if move.UserInputType == Enum.UserInputType.MouseMovement or move.UserInputType == Enum.UserInputType.Touch then update(move) end
	end)
	local ended
	ended = input.Changed:Connect(function()
		if input.UserInputState == Enum.UserInputState.End then
			if changed then changed:Disconnect() end
			if ended then ended:Disconnect() end
		end
	end)
end)
refresh()
optionapi.Object = slider
api.Options[optionsettings.Name] = optionapi
return optionapi
