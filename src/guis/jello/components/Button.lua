local optionapi = {Type = 'Button'}
local button = Instance.new('TextButton')
button.Name = optionsettings.Name..'Button'
button.Size = UDim2.new(1, -12, 0, 40)
button.BackgroundTransparency = 1
button.BorderSizePixel = 0
button.AutoButtonColor = false
button.Visible = optionsettings.Visible == nil or optionsettings.Visible
button.Text = optionsettings.Name
button.TextXAlignment = Enum.TextXAlignment.Left
button.TextColor3 = Color3.fromRGB(45, 151, 215)
button.TextSize = 17
button.FontFace = uipallet.Font
button.ZIndex = children.ZIndex + 1
button.Parent = children
local line = Instance.new('Frame')
line.Size = UDim2.new(1, 0, 0, 1)
line.Position = UDim2.new(0, 0, 1, -1)
line.BackgroundColor3 = Color3.fromRGB(232, 232, 232)
line.BorderSizePixel = 0
line.ZIndex = button.ZIndex
line.Parent = button
optionsettings.Function = optionsettings.Function or function() end
button.MouseButton1Click:Connect(optionsettings.Function)
optionapi.Object = button
return optionapi
