local optionapi = {
	Type = 'ColorSlider',
	Hue = optionsettings.DefaultHue or 0.54,
	Sat = optionsettings.DefaultSat or 1,
	Value = optionsettings.DefaultValue or 1,
	Opacity = optionsettings.DefaultOpacity or 1,
	Rainbow = false,
	Index = getTableSize(api.Options)
}
optionsettings.Function = optionsettings.Function or function() end
local card = Instance.new('Frame')
card.Name = optionsettings.Name..'ColorSlider'
card.Size = UDim2.new(1, -12, 0, 190)
card.BackgroundTransparency = 1
card.Visible = optionsettings.Visible == nil or optionsettings.Visible
card.ZIndex = children.ZIndex + 1
card.Parent = children
local title = Instance.new('TextLabel')
title.Size = UDim2.fromOffset(190, 36)
title.BackgroundTransparency = 1
title.Text = optionsettings.Name
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = uipallet.Text
title.TextSize = 20
title.FontFace = uipallet.Font
title.ZIndex = card.ZIndex + 1
title.Parent = card
local preview = Instance.new('Frame')
preview.Size = UDim2.fromOffset(38, 38)
preview.Position = UDim2.fromOffset(18, 48)
preview.BackgroundColor3 = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
preview.BorderSizePixel = 0
preview.ZIndex = card.ZIndex + 1
preview.Parent = card
addCorner(preview, UDim.new(1, 0))
local rainbow = Instance.new('TextButton')
rainbow.Size = UDim2.fromOffset(120, 34)
rainbow.Position = UDim2.fromOffset(12, 104)
rainbow.BackgroundTransparency = 1
rainbow.Text = 'Rainbow  ○'
rainbow.TextXAlignment = Enum.TextXAlignment.Left
rainbow.TextColor3 = uipallet.Muted
rainbow.TextSize = 16
rainbow.FontFace = uipallet.Font
rainbow.ZIndex = card.ZIndex + 1
rainbow.Parent = card
local sv = Instance.new('TextButton')
sv.Name = 'SaturationValue'
sv.Size = UDim2.new(1, -210, 0, 105)
sv.Position = UDim2.fromOffset(190, 34)
sv.BackgroundColor3 = Color3.fromHSV(optionapi.Hue, 1, 1)
sv.BorderSizePixel = 0
sv.AutoButtonColor = false
sv.Text = ''
sv.ClipsDescendants = true
sv.ZIndex = card.ZIndex + 1
sv.Parent = card
local white = Instance.new('Frame')
white.Size = UDim2.fromScale(1, 1)
white.BackgroundColor3 = Color3.new(1, 1, 1)
white.BorderSizePixel = 0
white.ZIndex = sv.ZIndex + 1
white.Parent = sv
local whiteGradient = Instance.new('UIGradient')
whiteGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
whiteGradient.Parent = white
local black = Instance.new('Frame')
black.Size = UDim2.fromScale(1, 1)
black.BackgroundColor3 = Color3.new(0, 0, 0)
black.BorderSizePixel = 0
black.ZIndex = sv.ZIndex + 2
black.Parent = sv
local blackGradient = Instance.new('UIGradient')
blackGradient.Rotation = 90
blackGradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
blackGradient.Parent = black
local cursor = Instance.new('Frame')
cursor.Size = UDim2.fromOffset(12, 12)
cursor.AnchorPoint = Vector2.new(0.5, 0.5)
cursor.BackgroundTransparency = 1
cursor.BorderSizePixel = 0
cursor.ZIndex = sv.ZIndex + 3
cursor.Parent = sv
local cursorStroke = Instance.new('UIStroke')
cursorStroke.Color = Color3.new(1, 1, 1)
cursorStroke.Thickness = 2
cursorStroke.Parent = cursor
addCorner(cursor, UDim.new(1, 0))
local hue = Instance.new('TextButton')
hue.Name = 'Hue'
hue.Size = UDim2.new(1, -250, 0, 11)
hue.Position = UDim2.fromOffset(200, 151)
hue.BackgroundColor3 = Color3.new(1, 1, 1)
hue.BorderSizePixel = 0
hue.AutoButtonColor = false
hue.Text = ''
hue.ZIndex = card.ZIndex + 1
hue.Parent = card
local rainbowColors = {}
for value = 0, 1, 0.1 do table.insert(rainbowColors, ColorSequenceKeypoint.new(value, Color3.fromHSV(value, 1, 1))) end
local hueGradient = Instance.new('UIGradient')
hueGradient.Color = ColorSequence.new(rainbowColors)
hueGradient.Parent = hue
local hueKnob = Instance.new('Frame')
hueKnob.Size = UDim2.fromOffset(8, 17)
hueKnob.AnchorPoint = Vector2.new(0.5, 0.5)
hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
hueKnob.BorderColor3 = Color3.fromRGB(135, 135, 135)
hueKnob.ZIndex = hue.ZIndex + 2
hueKnob.Parent = hue
local opacity = Instance.new('TextButton')
opacity.Size = UDim2.fromOffset(38, 11)
opacity.Position = UDim2.new(1, -41, 0, 151)
opacity.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
opacity.BorderSizePixel = 0
opacity.Text = ''
opacity.ZIndex = hue.ZIndex
opacity.Parent = card
local opacityFill = Instance.new('Frame')
opacityFill.Size = UDim2.fromScale(optionapi.Opacity, 1)
opacityFill.BackgroundColor3 = preview.BackgroundColor3
opacityFill.BorderSizePixel = 0
opacityFill.ZIndex = opacity.ZIndex + 1
opacityFill.Parent = opacity
local function refresh(fire)
	local selected = Color3.fromHSV(optionapi.Hue, optionapi.Sat, optionapi.Value)
	preview.BackgroundColor3 = selected
	sv.BackgroundColor3 = Color3.fromHSV(optionapi.Hue, 1, 1)
	cursor.Position = UDim2.fromScale(optionapi.Sat, 1 - optionapi.Value)
	hueKnob.Position = UDim2.fromScale(optionapi.Hue, 0.5)
	opacityFill.Size = UDim2.fromScale(optionapi.Opacity, 1)
	opacityFill.BackgroundColor3 = selected
	rainbow.Text = optionapi.Rainbow and 'Rainbow  ●' or 'Rainbow  ○'
	rainbow.TextColor3 = optionapi.Rainbow and uipallet.Accent or uipallet.Muted
	if fire then optionsettings.Function(optionapi.Hue, optionapi.Sat, optionapi.Value, optionapi.Opacity) end
end
function optionapi:Save(tab)
	tab[optionsettings.Name] = {Hue = self.Hue, Sat = self.Sat, Value = self.Value, Opacity = self.Opacity, Rainbow = self.Rainbow}
end
function optionapi:Load(tab)
	if type(tab) ~= 'table' then return end
	self.Hue = math.clamp(tonumber(tab.Hue) or self.Hue, 0, 1)
	self.Sat = math.clamp(tonumber(tab.Sat) or self.Sat, 0, 1)
	self.Value = math.clamp(tonumber(tab.Value) or self.Value, 0, 1)
	self.Opacity = math.clamp(tonumber(tab.Opacity) or self.Opacity, 0, 1)
	self.Rainbow = tab.Rainbow == true
	if self.Rainbow and not table.find(mainapi.RainbowTable, self) then table.insert(mainapi.RainbowTable, self) end
	refresh(true)
end
function optionapi:SetValue(h, s, v, o)
	self.Hue = math.clamp(tonumber(h) or self.Hue, 0, 1)
	self.Sat = math.clamp(tonumber(s) or self.Sat, 0, 1)
	self.Value = math.clamp(tonumber(v) or self.Value, 0, 1)
	self.Opacity = math.clamp(tonumber(o) or self.Opacity, 0, 1)
	refresh(true)
end
function optionapi:Toggle()
	self.Rainbow = not self.Rainbow
	local index = table.find(mainapi.RainbowTable, self)
	if self.Rainbow and not index then table.insert(mainapi.RainbowTable, self) elseif index then table.remove(mainapi.RainbowTable, index) end
	refresh(true)
end
local function drag(object, update)
	object.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
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
end
drag(sv, function(input)
	optionapi.Sat = math.clamp((input.Position.X - sv.AbsolutePosition.X) / sv.AbsoluteSize.X, 0, 1)
	optionapi.Value = 1 - math.clamp((input.Position.Y - sv.AbsolutePosition.Y) / sv.AbsoluteSize.Y, 0, 1)
	refresh(true)
end)
drag(hue, function(input)
	optionapi.Hue = math.clamp((input.Position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
	refresh(true)
end)
drag(opacity, function(input)
	optionapi.Opacity = math.clamp((input.Position.X - opacity.AbsolutePosition.X) / opacity.AbsoluteSize.X, 0, 1)
	refresh(true)
end)
rainbow.MouseButton1Click:Connect(function() optionapi:Toggle() end)
refresh(false)
optionapi.Object = card
api.Options[optionsettings.Name] = optionapi
return optionapi
