local mainapi = {
	Categories = {},
	GUIColor = {
		Hue = 0.46,
		Sat = 0.96,
		Value = 0.52
	},
	HeldKeybinds = {},
	Keybind = {'RightShift'},
	Loaded = false,
	Legit = {Modules = {}},
	Libraries = {},
	Modules = {},
	Place = game.PlaceId,
	Profile = 'default',
	ProfileCache = {},
	Profiles = {},
	RainbowSpeed = {Value = 1},
	RainbowUpdateSpeed = {Value = 60},
	RainbowTable = {},
	Scale = {Value = 1},
	ToggleNotifications = {},
	ThreadFix = setthreadidentity and true or false,
	Version = 'Jello 1.0',
	Windows = {}
}

local cloneref = cloneref or function(obj)
	return obj
end
local tweenService = cloneref(game:GetService('TweenService'))
local inputService = cloneref(game:GetService('UserInputService'))
local textService = cloneref(game:GetService('TextService'))
local guiService = cloneref(game:GetService('GuiService'))
local runService = cloneref(game:GetService('RunService'))
local httpService = cloneref(game:GetService('HttpService'))

local fontsize = Instance.new('GetTextBoundsParams')
fontsize.Width = math.huge
local notifications
local assetfunction = getcustomasset or getsynasset
local getcustomasset
local clickgui
local scaledgui
local tooltip
local scale
local gui

local color = {}
local tween = {
	tweens = {},
	tweenstwo = {}
}
local uipallet = {
	Main = Color3.fromRGB(244, 244, 244),
	Panel = Color3.fromRGB(250, 250, 250),
	Text = Color3.fromRGB(42, 42, 42),
	Muted = Color3.fromRGB(137, 137, 137),
	Accent = Color3.fromRGB(0, 183, 234),
	Font = Font.fromEnum(Enum.Font.Arial),
	FontSemiBold = Font.fromEnum(Enum.Font.Arial, Enum.FontWeight.Medium),
	Tween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

local getcustomassets = {
	['newvape/assets/jello/barlogo.png'] = 'rbxasset://barlogo.png',
	['newvape/assets/jello/blatanticon.png'] = 'rbxasset://blatanticon.png',
	['newvape/assets/jello/checkbox.png'] = 'rbxasset://checkbox.png',
	['newvape/assets/jello/combaticon.png'] = 'rbxasset://combaticon.png',
	['newvape/assets/jello/friendsicon.png'] = 'rbxasset://friendsicon.png',
	['newvape/assets/jello/guiicon.png'] = 'rbxasset://guiicon.png',
	['newvape/assets/jello/info.png'] = 'rbxasset://info.png',
	['newvape/assets/jello/pin.png'] = 'rbxasset://pin.png',
	['newvape/assets/jello/profilesicon.png'] = 'rbxasset://profilesicon.png',
	['newvape/assets/jello/rendericon.png'] = 'rbxasset://rendericon.png',
	['newvape/assets/jello/search.png'] = 'rbxasset://search.png',
	['newvape/assets/jello/settingsicon.png'] = 'rbxasset://settingsicon.png',
	['newvape/assets/jello/targetinfoicon.png'] = 'rbxasset://targetinfoicon.png',
	['newvape/assets/jello/textguiicon.png'] = 'rbxasset://textguiicon.png',
	['newvape/assets/jello/textv4.png'] = 'rbxasset://textv4.png',
	['newvape/assets/jello/textvape.png'] = 'rbxasset://textvape.png',
	['newvape/assets/jello/utilityicon.png'] = 'rbxasset://utilityicon.png',
	['newvape/assets/jello/vape.png'] = 'rbxassetid://14373395239',
	['newvape/assets/jello/worldicon.png'] = 'rbxasset://worldicon.png',
	['newvape/assets/jello/jelloregular.ttf'] = ''
}

local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end

local getfontsize = function(text, size, font)
	fontsize.Text = text
	fontsize.Size = size
	if typeof(font) == 'Font' then
		fontsize.Font = font
	end
	return textService:GetTextBoundsAsync(fontsize)
end

local function addCorner(parent, radius)
	local corner = Instance.new('UICorner')
	corner.CornerRadius = radius or UDim.new(0, 5)
	corner.Parent = parent

	return corner
end

local function addMaid(object)
	object.Connections = {}
	function object:Clean(callback)
		if typeof(callback) == 'Instance' then
			table.insert(self.Connections, {
				Disconnect = function()
					callback:ClearAllChildren()
					callback:Destroy()
				end
			})
		elseif type(callback) == 'function' then
			table.insert(self.Connections, {
				Disconnect = callback
			})
		else
			table.insert(self.Connections, callback)
		end
	end
end

local function addTooltip(gui, text)
	if not text then return end

	local function tooltipMoved(x, y)
		local right = x + 16 + tooltip.Size.X.Offset > (scale.Scale * 1920)
		tooltip.Position = UDim2.fromOffset((right and x - (tooltip.Size.X.Offset * scale.Scale) - 16 or x + 16) / scale.Scale, ((y + 11) - (tooltip.Size.Y.Offset / 2)) / scale.Scale)
		tooltip.Visible = true
	end

	gui.MouseEnter:Connect(function(x, y)
		local tooltipSize = getfontsize(text, tooltip.TextSize, uipallet.Font)
		tooltip.Size = UDim2.fromOffset(tooltipSize.X + 10, tooltipSize.Y + 6)
		tooltip.Text = text
		tooltipMoved(x, y)
	end)
	gui.MouseMoved:Connect(tooltipMoved)
	gui.MouseLeave:Connect(function()
		tooltip.Visible = false
	end)
end

local function bindKeys(value, fallback)
	if type(value) == 'table' and type(value.Keys) == 'table' then value = value.Keys end
	local keys = {}
	if type(value) == 'table' then
		for _, key in value do
			if type(key) == 'string' and key ~= '' then table.insert(keys, key) end
		end
	end
	if #keys == 0 and type(fallback) == 'table' then return table.clone(fallback) end
	return keys
end

local function checkKeybinds(compare, target, key)
	compare = bindKeys(compare)
	target = bindKeys(target)
	if not table.find(target, key) then return false end
	for _, value in target do
		if not table.find(compare, value) then return false end
	end
	return true
end

local function createDownloader(text)
	if mainapi.Loaded ~= true then
		local downloader = mainapi.Downloader
		if not downloader then
			downloader = Instance.new('TextLabel')
			downloader.Size = UDim2.new(1, 0, 0, 40)
			downloader.BackgroundTransparency = 1
			downloader.TextStrokeTransparency = 0
			downloader.TextSize = 20
			downloader.TextColor3 = Color3.new(1, 1, 1)
			downloader.FontFace = uipallet.Font
			downloader.Parent = mainapi.gui
			mainapi.Downloader = downloader
		end
		downloader.Text = 'Downloading '..text
	end
end

local function createMobileButton(buttonapi, position)
	local heldbutton = false
	local button = Instance.new('TextButton')
	button.Size = UDim2.fromOffset(40, 40)
	button.Position = UDim2.fromOffset(position.X, position.Y)
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.BackgroundColor3 = buttonapi.Enabled and Color3.new(0, 0.7, 0) or Color3.new()
	button.Text = buttonapi.Name
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextScaled = true
	button.FontFace = uipallet.Font
	button.Parent = mainapi.gui
	local buttonconstraint = Instance.new('UITextSizeConstraint')
	buttonconstraint.MaxTextSize = 16
	buttonconstraint.Parent = button

	button.MouseButton1Down:Connect(function()
		heldbutton = true
		local holdtime, holdpos = tick(), inputService:GetMouseLocation()
		repeat
			heldbutton = (inputService:GetMouseLocation() - holdpos).Magnitude < 6
			task.wait()
		until (tick() - holdtime) > 1 or not heldbutton
		if heldbutton then
			buttonapi.Bind = {}
			button:Destroy()
		end
	end)
	button.MouseButton1Up:Connect(function()
		heldbutton = false
	end)
	button.MouseButton1Click:Connect(function()
		buttonapi:Toggle()
		button.BackgroundColor3 = buttonapi.Enabled and Color3.new(0, 0.7, 0) or Color3.new()
	end)

	buttonapi.Bind = {Button = button}
end

local function downloadFile(path, func)
	if not isfile(path) then
		createDownloader(path)
		local suc, res = pcall(function()
			local remotePath = select(1, path:gsub('newvape/', ''))
			remotePath = remotePath:gsub('^assets/jello/', 'guis/jello/assets/')
			local sourceRef = isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or 'main'
			return game:HttpGet('https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/'..sourceRef..'/src/'..remotePath, true)
		end)
		if not suc or res == '404: Not Found' then
			if getcustomassets[path] then return getcustomassets[path] end
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

getcustomasset = not inputService.TouchEnabled and assetfunction and function(path)
	local mapped = shared.VapeAssetPaths and shared.VapeAssetPaths[path]
	return mapped and assetfunction(mapped) or downloadFile(path, assetfunction)
end or function(path)
	return getcustomassets[path] or ''
end

local function loadJelloFont()
	if not assetfunction then return end
	local success = pcall(function()
		local familyPath = 'newvape/assets/jello/jellofont.json'
		writefile(familyPath, httpService:JSONEncode({
			name = 'Helvetica Neue',
			faces = {{
				name = 'Regular',
				weight = 400,
				style = 'normal',
				assetId = getcustomasset('newvape/assets/jello/jelloregular.ttf')
			}}
		}))
		local family = getcustomasset(familyPath)
		uipallet.Font = Font.new(family, Enum.FontWeight.Regular)
		uipallet.FontSemiBold = Font.new(family, Enum.FontWeight.Medium)
	end)
	if not success then
		uipallet.Font = Font.fromEnum(Enum.Font.Arial)
		uipallet.FontSemiBold = Font.fromEnum(Enum.Font.Arial, Enum.FontWeight.Medium)
	end
end

local function getTableSize(tab)
	local ind = 0
	for _ in tab do ind += 1 end
	return ind
end

local function loopClean(tab)
	for i, v in tab do
		if type(v) == 'table' then
			loopClean(v)
		end
		tab[i] = nil
	end
end

local function loadJson(path)
	local suc, res = pcall(function()
		return httpService:JSONDecode(readfile(path))
	end)
	return suc and type(res) == 'table' and res or nil
end

local profileFiles = {}
local function profileNameFromPath(path)
	local file = tostring(path):gsub('\\', '/'):match('([^/]+)$') or ''
	if file:sub(-4):lower() ~= '.txt' then return end
	local name = file:sub(1, -5)
	if name == 'gui' or name == 'color' or name == 'commit' or name == 'whitelist' or name:sub(-4) == '.gui' then return end
	local place = tostring(game.PlaceId)
	if name:sub(-#place) == place then return name:sub(1, -#place - 1), 3 end
	local prefix, digits = name:match('^(.-)(%d+)$')
	if prefix and prefix ~= '' and #digits >= 6 then return prefix, 1 end
	return name, 2
end

local function discoverProfiles(savedProfiles)
	table.clear(profileFiles)
	local profiles, known = {}, {}
	local function add(entry)
		if type(entry) ~= 'table' or type(entry.Name) ~= 'string' or entry.Name == '' then return end
		local current = known[entry.Name]
		if current then
			if #bindKeys(current.Bind) == 0 and #bindKeys(entry.Bind) > 0 then current.Bind = entry.Bind end
			return
		end
		current = {Name = entry.Name, Bind = entry.Bind or {}}
		known[entry.Name] = current
		table.insert(profiles, current)
	end
	for _, entry in (type(savedProfiles) == 'table' and savedProfiles or {}) do add(entry) end
	add({Name = 'default', Bind = {}})

	if type(listfiles) == 'function' then
		local success, files = pcall(listfiles, 'newvape/profiles')
		if success and type(files) == 'table' then
			for _, path in files do
				local name, score = profileNameFromPath(path)
				local data = name and loadJson(path)
				if data and (type(data.Modules) == 'table' or type(data.Legit) == 'table') then
					local current = profileFiles[name]
					if not current or score > current.Score then profileFiles[name] = {Path = path, Score = score} end
					add({Name = name, Bind = {}})
				end
			end
		end
	end
	return profiles
end

local function getProfilePath(name)
	local canonical = 'newvape/profiles/'..name..game.PlaceId..'.txt'
	if isfile(canonical) then return canonical end
	local portable = 'newvape/profiles/'..name..'.txt'
	if isfile(portable) then return portable end
	return profileFiles[name] and profileFiles[name].Path or nil
end

local function makeDraggable(gui, window)
	gui.InputBegan:Connect(function(inputObj)
		if window and not window.Visible then return end
		if
			(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
			and (inputObj.Position.Y - gui.AbsolutePosition.Y < 40 or window)
		then
			local dragPosition = Vector2.new(gui.AbsolutePosition.X - inputObj.Position.X, gui.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y) / scale.Scale
			local changed = inputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position = input.Position
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end
					gui.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
				end
			end)

			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					if changed then
						changed:Disconnect()
					end
					if ended then
						ended:Disconnect()
					end
				end
			end)
		end
	end)
end

local function randomString()
	local array = {}
	for i = 1, math.random(10, 100) do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

local function removeTags(str)
	str = str:gsub('<br%s*/>', '\n')
	return str:gsub('<[^<>]->', '')
end

do
	local res = isfile('newvape/profiles/color.txt') and loadJson('newvape/profiles/color.txt')
	if res then
		-- Jello keeps its original light palette and typeface independent of Vape themes.
	end
	loadJelloFont()
	fontsize.Font = uipallet.Font
end

do
	function color.Dark(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v + num or v - num, 0, 1))
	end

	function color.Light(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(select(3, uipallet.Main:ToHSV()) > 0.5 and v - num or v + num, 0, 1))
	end

	function mainapi:Color(h)
		local s = 0.75 + (0.15 * math.min(h / 0.03, 1))
		if h > 0.57 then
			s = 0.9 - (0.4 * math.min((h - 0.57) / 0.09, 1))
		end
		if h > 0.66 then
			s = 0.5 + (0.4 * math.min((h - 0.66) / 0.16, 1))
		end
		if h > 0.87 then
			s = 0.9 - (0.15 * math.min((h - 0.87) / 0.13, 1))
		end
		return h, s, 1
	end

	function mainapi:TextColor(h, s, v, col)
		if v < 0.7 then
			return Color3.new(1, 1, 1)
		end
		if s < 0.6 or h > 0.04 and h < 0.56 then
			return col or color.Light(uipallet.Main, 0.14)
		end
		return Color3.new(1, 1, 1)
	end
end

do
	function tween:Tween(obj, tweeninfo, goal, tab)
		tab = tab or self.tweens
		if tab[obj] then
			tab[obj]:Cancel()
			tab[obj] = nil
		end

		if obj.Parent and obj.Visible then
			tab[obj] = tweenService:Create(obj, tweeninfo, goal)
			tab[obj].Completed:Once(function()
				if tab then
					tab[obj] = nil
					tab = nil
				end
			end)
			tab[obj]:Play()
		else
			for i, v in goal do
				obj[i] = v
			end
		end
	end

	function tween:Cancel(obj)
		if self.tweens[obj] then
			self.tweens[obj]:Cancel()
			self.tweens[obj] = nil
		end
	end
end

mainapi.Libraries = {
	color = color,
	getcustomasset = getcustomasset,
	getfontsize = getfontsize,
	tween = tween,
	uipallet = uipallet,
}

local components
components = {
--Components
	Divider = function(children, text)
		local divider = Instance.new('Frame')
		divider.Name = 'Divider'
		divider.Size = UDim2.new(1, 0, 0, 1)
		divider.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		divider.BorderSizePixel = 0
		divider.Parent = children
		if text then
			local label = Instance.new('TextLabel')
			label.Name = 'DividerLabel'
			label.Size = UDim2.fromOffset(218, 27)
			label.BackgroundTransparency = 1
			label.Text = '          '..text:upper()
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextColor3 = color.Dark(uipallet.Text, 0.43)
			label.TextSize = 9
			label.FontFace = uipallet.Font
			label.Parent = children
			divider.Position = UDim2.fromOffset(0, 26)
			divider.Parent = label
		end
	end
}

mainapi.Components = setmetatable(components, {
	__newindex = function(self, ind, func)
		for _, v in mainapi.Modules do
			rawset(v, 'Create'..ind, function(_, settings)
				return func(settings, v.Children, v)
			end)
		end
		if mainapi.Legit then
			for _, v in mainapi.Legit.Modules do
				rawset(v, 'Create'..ind, function(_, settings)
					return func(settings, v.Children, v)
				end)
			end
		end
		rawset(self, ind, func)
	end
})

task.spawn(function()
	repeat
		local hue = tick() * (0.2 * mainapi.RainbowSpeed.Value) % 1
		for _, v in mainapi.RainbowTable do
			if v.Type == 'GUISlider' then
				v:SetValue(mainapi:Color(hue))
			else
				v:SetValue(hue)
			end
		end
		task.wait(1 / mainapi.RainbowUpdateSpeed.Value)
	until mainapi.Loaded == nil
end)

function mainapi:BlurCheck()
	if self.ThreadFix then
		setthreadidentity(8)
		runService:SetRobloxGuiFocused((clickgui.Visible or guiService:GetErrorType() ~= Enum.ConnectionError.OK) and self.Blur.Enabled)
	end
end

addMaid(mainapi)

function mainapi:CreateBar()
	local categoryapi = {
		Type = 'Category',
		Expanded = true,
		Options = {},
		TopBar = true
	}

	local bar = Instance.new('Frame')
	bar.Name = 'JelloBar'
	bar.Size = UDim2.fromOffset(490, 62)
	bar.Position = UDim2.fromOffset(8, 4)
	bar.BackgroundTransparency = 1
	bar.BorderSizePixel = 0
	bar.Parent = clickgui

	local logo = Instance.new('TextLabel')
	logo.Size = UDim2.fromOffset(100, 38)
	logo.Position = UDim2.fromOffset(0, 0)
	logo.BackgroundTransparency = 1
	logo.Text = 'Sigma'
	logo.TextXAlignment = Enum.TextXAlignment.Left
	logo.TextColor3 = Color3.fromRGB(238, 238, 238)
	logo.TextSize = 28
	logo.FontFace = uipallet.Font
	logo.Parent = bar
	local sublogo = logo:Clone()
	sublogo.Size = UDim2.fromOffset(80, 16)
	sublogo.Position = UDim2.fromOffset(2, 31)
	sublogo.Text = 'Jello'
	sublogo.TextSize = 12
	sublogo.TextColor3 = Color3.fromRGB(206, 206, 206)
	sublogo.Parent = bar

	local settingsbutton = Instance.new('TextButton')
	settingsbutton.Size = UDim2.fromOffset(94, 28)
	settingsbutton.Position = UDim2.fromOffset(382, 9)
	settingsbutton.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
	settingsbutton.BackgroundTransparency = 0.08
	settingsbutton.BorderSizePixel = 0
	settingsbutton.Text = 'Settings'
	settingsbutton.TextColor3 = uipallet.Text
	settingsbutton.TextSize = 14
	settingsbutton.FontFace = uipallet.Font
	settingsbutton.AutoButtonColor = false
	settingsbutton.Parent = bar
	addCorner(settingsbutton, UDim.new(0, 3))

	local children = Instance.new('ScrollingFrame')
	children.Name = 'JelloSettings'
	children.Size = UDim2.fromOffset(330, 560)
	children.Position = UDim2.fromOffset(158, 44)
	children.BackgroundColor3 = uipallet.Panel
	children.BorderSizePixel = 0
	children.Visible = false
	children.ScrollBarThickness = 2
	children.ScrollBarImageColor3 = uipallet.Accent
	children.CanvasSize = UDim2.new()
	children.Parent = bar
	addCorner(children, UDim.new(0, 8))
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Padding = UDim.new(0, 2)
	windowlist.Parent = children

	local managerButton = settingsbutton:Clone()
	managerButton.Name = 'KeybindManagerButton'
	managerButton.Size = UDim2.fromOffset(148, 28)
	managerButton.Position = UDim2.fromOffset(112, 9)
	managerButton.Text = 'Keybind Manager'
	managerButton.Parent = bar

	local musicButton = settingsbutton:Clone()
	musicButton.Name = 'JelloMusicButton'
	musicButton.Size = UDim2.fromOffset(104, 28)
	musicButton.Position = UDim2.fromOffset(270, 9)
	musicButton.Text = 'Jello Music'
	musicButton.Parent = bar

	local function makePanel(name, size)
		local panel = Instance.new('Frame')
		panel.Name = name
		panel.Size = size
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.BackgroundColor3 = uipallet.Panel
		panel.BorderSizePixel = 0
		panel.Visible = false
		panel.ZIndex = 20
		panel.Parent = clickgui
		addCorner(panel, UDim.new(0, 12))
		table.insert(mainapi.Windows, panel)
		return panel
	end

	local keyManager = makePanel('KeybindManager', UDim2.fromOffset(1110, 452))
	local managerTitle = Instance.new('TextLabel')
	managerTitle.Size = UDim2.new(1, -38, 0, 65)
	managerTitle.Position = UDim2.fromOffset(22, 5)
	managerTitle.BackgroundTransparency = 1
	managerTitle.Text = 'Keybind Manager'
	managerTitle.TextXAlignment = Enum.TextXAlignment.Left
	managerTitle.TextColor3 = Color3.fromRGB(68, 68, 68)
	managerTitle.TextSize = 35
	managerTitle.FontFace = uipallet.Font
	managerTitle.ZIndex = 21
	managerTitle.Parent = keyManager
	local managerClose = Instance.new('TextButton')
	managerClose.Size = UDim2.fromOffset(42, 42)
	managerClose.Position = UDim2.new(1, -52, 0, 12)
	managerClose.BackgroundTransparency = 1
	managerClose.Text = '×'
	managerClose.TextColor3 = uipallet.Muted
	managerClose.TextSize = 30
	managerClose.FontFace = uipallet.Font
	managerClose.ZIndex = 25
	managerClose.Parent = keyManager

	local keyboard = Instance.new('Frame')
	keyboard.Size = UDim2.new(1, -40, 1, -82)
	keyboard.Position = UDim2.fromOffset(20, 70)
	keyboard.BackgroundTransparency = 1
	keyboard.ZIndex = 21
	keyboard.Parent = keyManager
	local keyboardList = Instance.new('UIListLayout')
	keyboardList.Padding = UDim.new(0, 7)
	keyboardList.SortOrder = Enum.SortOrder.LayoutOrder
	keyboardList.Parent = keyboard

	local details
	local selector
	local keyboardRows = {
		{{'Backquote', '`'}, {'One', '1'}, {'Two', '2'}, {'Three', '3'}, {'Four', '4'}, {'Five', '5'}, {'Six', '6'}, {'Seven', '7'}, {'Eight', '8'}, {'Nine', '9'}, {'Zero', '0'}, {'Minus', '-'}, {'Equals', '='}, {'Backspace', '←', 1.8}},
		{{'Tab', 'Tab', 1.45}, {'Q', 'Q'}, {'W', 'W'}, {'E', 'E'}, {'R', 'R'}, {'T', 'T'}, {'Y', 'Y'}, {'U', 'U'}, {'I', 'I'}, {'O', 'O'}, {'P', 'P'}, {'LeftBracket', '['}, {'RightBracket', ']'}, {'BackSlash', '\\', 1.3}},
		{{'CapsLock', 'Caps Lock', 1.75}, {'A', 'A'}, {'S', 'S'}, {'D', 'D'}, {'F', 'F'}, {'G', 'G'}, {'H', 'H'}, {'J', 'J'}, {'K', 'K'}, {'L', 'L'}, {'Semicolon', ';'}, {'Quote', "'"}, {'Return', '↵', 1.8}},
		{{'LeftShift', 'Shift', 2.2}, {'Z', 'Z'}, {'X', 'X'}, {'C', 'C'}, {'V', 'V'}, {'B', 'B'}, {'N', 'N'}, {'M', 'M'}, {'Comma', ','}, {'Period', '.'}, {'Slash', '/'}, {'RightShift', 'Shift', 2.2}},
		{{'LeftControl', 'Ctrl', 1.3}, {'LeftAlt', 'Alt', 1.3}, {'Space', '', 6.1}, {'RightAlt', 'Alt Gr', 1.4}, {'RightControl', 'Ctrl', 1.3}}
	}

	local function moduleUsesKey(module, key)
		return table.find(bindKeys(module.Bind), key) ~= nil
	end

	local function openSelector(key, reopen)
		if selector then selector:Destroy() end
		selector = Instance.new('Frame')
		selector.Name = 'ModuleSelector'
		selector.Size = UDim2.fromOffset(500, 570)
		selector.Position = UDim2.fromScale(0.5, 0.5)
		selector.AnchorPoint = Vector2.new(0.5, 0.5)
		selector.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
		selector.BorderSizePixel = 0
		selector.ZIndex = 40
		selector.Parent = keyManager
		addCorner(selector, UDim.new(0, 10))
		local title = Instance.new('TextLabel')
		title.Size = UDim2.new(1, -40, 0, 62)
		title.Position = UDim2.fromOffset(20, 8)
		title.BackgroundTransparency = 1
		title.Text = 'Select mod to bind'
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = uipallet.Text
		title.TextSize = 34
		title.FontFace = uipallet.Font
		title.ZIndex = 41
		title.Parent = selector
		local search = Instance.new('TextBox')
		search.Size = UDim2.new(1, -56, 0, 46)
		search.Position = UDim2.fromOffset(28, 70)
		search.BackgroundTransparency = 1
		search.PlaceholderText = 'Search...'
		search.PlaceholderColor3 = Color3.fromRGB(177, 177, 177)
		search.Text = ''
		search.TextColor3 = uipallet.Text
		search.TextSize = 24
		search.TextXAlignment = Enum.TextXAlignment.Left
		search.FontFace = uipallet.Font
		search.ClearTextOnFocus = false
		search.ZIndex = 41
		search.Parent = selector
		local line = Instance.new('Frame')
		line.Size = UDim2.new(1, -58, 0, 1)
		line.Position = UDim2.fromOffset(29, 114)
		line.BackgroundColor3 = Color3.fromRGB(172, 172, 172)
		line.BorderSizePixel = 0
		line.ZIndex = 41
		line.Parent = selector
		local list = Instance.new('ScrollingFrame')
		list.Size = UDim2.new(1, -42, 1, -144)
		list.Position = UDim2.fromOffset(21, 130)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 2
		list.ScrollBarImageColor3 = uipallet.Accent
		list.CanvasSize = UDim2.new()
		list.ZIndex = 41
		list.Parent = selector
		local layout = Instance.new('UIListLayout')
		layout.SortOrder = Enum.SortOrder.Name
		layout.Parent = list
		local rows = {}
		local function addChoice(name, callback)
			local row = Instance.new('TextButton')
			row.Name = name
			row.Size = UDim2.new(1, -8, 0, 39)
			row.BackgroundTransparency = 1
			row.Text = name
			row.TextColor3 = uipallet.Text
			row.TextSize = 22
			row.FontFace = uipallet.Font
			row.ZIndex = 42
			row.Parent = list
			row.MouseButton1Click:Connect(function()
				callback()
				selector:Destroy()
				selector = nil
				reopen()
			end)
			table.insert(rows, row)
		end
		addChoice('Click GUI', function()
			mainapi.Categories.TopBar.Options.Bind:SetBind({key})
		end)
		for name, module in mainapi.Modules do
			if module.Category ~= 'GUI' then
				addChoice(name, function() module:SetBind({key}) end)
			end
		end
		layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
		end)
		search:GetPropertyChangedSignal('Text'):Connect(function()
			local query = search.Text:lower()
			for _, row in rows do row.Visible = query == '' or row.Name:lower():find(query, 1, true) ~= nil end
		end)
	end

	local function showKeyDetails(key, keyButton)
		if details then details:Destroy() end
		details = Instance.new('Frame')
		details.Name = key..'Details'
		details.Size = UDim2.fromOffset(270, 330)
		local point = (keyButton.AbsolutePosition - keyManager.AbsolutePosition) / scale.Scale
		details.Position = UDim2.fromOffset(math.clamp(point.X - 40, 12, 820), math.clamp(point.Y + 52, 75, 108))
		details.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
		details.BorderSizePixel = 0
		details.ZIndex = 30
		details.Parent = keyManager
		addCorner(details, UDim.new(0, 9))
		local title = Instance.new('TextLabel')
		title.Size = UDim2.new(1, -36, 0, 60)
		title.Position = UDim2.fromOffset(18, 4)
		title.BackgroundTransparency = 1
		title.Text = keyButton.Text..' Key'
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = uipallet.Text
		title.TextSize = 25
		title.FontFace = uipallet.Font
		title.ZIndex = 31
		title.Parent = details
		local divider = Instance.new('Frame')
		divider.Size = UDim2.new(1, -36, 0, 1)
		divider.Position = UDim2.fromOffset(18, 61)
		divider.BackgroundColor3 = Color3.fromRGB(228, 228, 228)
		divider.BorderSizePixel = 0
		divider.ZIndex = 31
		divider.Parent = details
		local assigned = Instance.new('ScrollingFrame')
		assigned.Size = UDim2.new(1, -28, 1, -120)
		assigned.Position = UDim2.fromOffset(14, 72)
		assigned.BackgroundTransparency = 1
		assigned.BorderSizePixel = 0
		assigned.ScrollBarThickness = 0
		assigned.ZIndex = 31
		assigned.Parent = details
		local assignedLayout = Instance.new('UIListLayout')
		assignedLayout.Parent = assigned
		assignedLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			assigned.CanvasSize = UDim2.fromOffset(0, assignedLayout.AbsoluteContentSize.Y)
		end)
		local function assignment(name, subtitle, remove)
			local row = Instance.new('Frame')
			row.Size = UDim2.new(1, 0, 0, 52)
			row.BackgroundTransparency = 1
			row.ZIndex = 32
			row.Parent = assigned
			local label = title:Clone()
			label.Size = UDim2.new(1, -42, 0, 27)
			label.Position = UDim2.fromOffset(3, 0)
			label.Text = name
			label.TextSize = 19
			label.ZIndex = 33
			label.Parent = row
			local sub = label:Clone()
			sub.Position = UDim2.fromOffset(3, 25)
			sub.Text = subtitle or ''
			sub.TextColor3 = uipallet.Muted
			sub.TextSize = 12
			sub.Parent = row
			local removeButton = Instance.new('TextButton')
			removeButton.Size = UDim2.fromOffset(20, 20)
			removeButton.Position = UDim2.new(1, -27, 0, 9)
			removeButton.BackgroundColor3 = Color3.fromRGB(255, 151, 151)
			removeButton.Text = '−'
			removeButton.TextColor3 = Color3.new(1, 1, 1)
			removeButton.TextSize = 19
			removeButton.FontFace = uipallet.FontSemiBold
			removeButton.ZIndex = 34
			removeButton.Parent = row
			addCorner(removeButton, UDim.new(1, 0))
			removeButton.MouseButton1Click:Connect(function()
				remove()
				showKeyDetails(key, keyButton)
			end)
		end
		if table.find(bindKeys(mainapi.Keybind), key) then
			assignment('Click GUI', 'Interface', function()
				mainapi.Categories.TopBar.Options.Bind:SetBind({'RightShift'})
			end)
		end
		for name, module in mainapi.Modules do
			if moduleUsesKey(module, key) then
				assignment(name, module.Category, function() module:SetBind({}) end)
			end
		end
		local add = Instance.new('TextButton')
		add.Size = UDim2.fromOffset(78, 43)
		add.Position = UDim2.new(1, -92, 1, -52)
		add.BackgroundTransparency = 1
		add.Text = 'Add'
		add.TextColor3 = Color3.fromRGB(54, 158, 218)
		add.TextSize = 24
		add.FontFace = uipallet.Font
		add.ZIndex = 33
		add.Parent = details
		add.MouseButton1Click:Connect(function()
			openSelector(key, function() showKeyDetails(key, keyButton) end)
		end)
	end

	for rowIndex, rowData in keyboardRows do
		local row = Instance.new('Frame')
		row.Name = 'Row'..rowIndex
		row.Size = UDim2.new(1, 0, 0, 62)
		row.BackgroundTransparency = 1
		row.LayoutOrder = rowIndex
		row.ZIndex = 21
		row.Parent = keyboard
		local rowList = Instance.new('UIListLayout')
		rowList.FillDirection = Enum.FillDirection.Horizontal
		rowList.Padding = UDim.new(0, 7)
		rowList.Parent = row
		for _, data in rowData do
			local keyButton = Instance.new('TextButton')
			keyButton.Name = data[1]
			keyButton.Size = UDim2.fromOffset(60 * (data[3] or 1), 60)
			keyButton.BackgroundColor3 = Color3.fromRGB(238, 238, 238)
			keyButton.BorderSizePixel = 0
			keyButton.AutoButtonColor = false
			keyButton.Text = data[2]
			keyButton.TextColor3 = Color3.fromRGB(119, 119, 119)
			keyButton.TextSize = 19
			keyButton.FontFace = uipallet.Font
			keyButton.ZIndex = 22
			keyButton.Parent = row
			addCorner(keyButton, UDim.new(0, 7))
			local shadow = Instance.new('UIStroke')
			shadow.Color = Color3.fromRGB(218, 218, 218)
			shadow.Thickness = 1
			shadow.Transparency = 0.35
			shadow.Parent = keyButton
			keyButton.MouseButton1Click:Connect(function() showKeyDetails(data[1], keyButton) end)
		end
	end

	local music = makePanel('JelloMusic', UDim2.fromOffset(390, 315))
	music.BackgroundColor3 = Color3.fromRGB(20, 21, 26)
	local musicTitle = managerTitle:Clone()
	musicTitle.Size = UDim2.new(1, -40, 0, 56)
	musicTitle.Position = UDim2.fromOffset(20, 5)
	musicTitle.Text = 'Jello'
	musicTitle.TextColor3 = Color3.new(1, 1, 1)
	musicTitle.TextSize = 28
	musicTitle.Parent = music
	local musicSmall = musicTitle:Clone()
	musicSmall.Position = UDim2.fromOffset(89, 20)
	musicSmall.Text = 'Music'
	musicSmall.TextSize = 13
	musicSmall.TextColor3 = Color3.fromRGB(205, 205, 205)
	musicSmall.Parent = music
	local musicClose = managerClose:Clone()
	musicClose.TextColor3 = Color3.fromRGB(190, 190, 195)
	musicClose.Parent = music
	local trackName = musicTitle:Clone()
	trackName.Size = UDim2.new(1, -40, 0, 32)
	trackName.Position = UDim2.fromOffset(20, 72)
	trackName.Text = 'No track loaded'
	trackName.TextSize = 18
	trackName.Parent = music
	local assetBox = Instance.new('TextBox')
	assetBox.Size = UDim2.new(1, -40, 0, 44)
	assetBox.Position = UDim2.fromOffset(20, 120)
	assetBox.BackgroundColor3 = Color3.fromRGB(35, 36, 43)
	assetBox.BorderSizePixel = 0
	assetBox.PlaceholderText = 'Roblox audio asset ID'
	assetBox.PlaceholderColor3 = Color3.fromRGB(135, 135, 140)
	assetBox.Text = ''
	assetBox.TextColor3 = Color3.new(1, 1, 1)
	assetBox.TextSize = 17
	assetBox.FontFace = uipallet.Font
	assetBox.ClearTextOnFocus = false
	assetBox.ZIndex = 22
	assetBox.Parent = music
	addCorner(assetBox, UDim.new(0, 4))
	local sound = Instance.new('Sound')
	sound.Name = 'JelloMusicPlayer'
	sound.Volume = 0.5
	sound.Parent = gui
	local play = Instance.new('TextButton')
	play.Size = UDim2.fromOffset(74, 52)
	play.Position = UDim2.new(0.5, -37, 0, 184)
	play.BackgroundTransparency = 1
	play.Text = '▶'
	play.TextColor3 = Color3.new(1, 1, 1)
	play.TextSize = 29
	play.FontFace = uipallet.Font
	play.ZIndex = 22
	play.Parent = music
	local volume = Instance.new('TextButton')
	volume.Size = UDim2.new(1, -60, 0, 20)
	volume.Position = UDim2.fromOffset(30, 264)
	volume.BackgroundColor3 = Color3.fromRGB(72, 72, 80)
	volume.BorderSizePixel = 0
	volume.Text = ''
	volume.ZIndex = 22
	volume.Parent = music
	addCorner(volume, UDim.new(1, 0))
	local volumeFill = Instance.new('Frame')
	volumeFill.Size = UDim2.fromScale(0.5, 1)
	volumeFill.BackgroundColor3 = Color3.fromRGB(207, 43, 100)
	volumeFill.BorderSizePixel = 0
	volumeFill.ZIndex = 23
	volumeFill.Parent = volume
	addCorner(volumeFill, UDim.new(1, 0))
	local function setVolume(input)
		local value = math.clamp((input.Position.X - volume.AbsolutePosition.X) / volume.AbsoluteSize.X, 0, 1)
		sound.Volume = value
		volumeFill.Size = UDim2.fromScale(value, 1)
	end
	volume.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then setVolume(input) end
	end)
	play.MouseButton1Click:Connect(function()
		if sound.Playing then
			sound:Pause()
			play.Text = '▶'
			return
		end
		local id = assetBox.Text:match('%d+')
		if id then
			sound.SoundId = 'rbxassetid://'..id
			trackName.Text = 'Asset '..id
		end
		if sound.SoundId ~= '' then
			sound:Play()
			play.Text = 'Ⅱ'
		end
	end)

	managerButton.MouseButton1Click:Connect(function()
		keyManager.Visible = not keyManager.Visible
		music.Visible = false
	end)
	musicButton.MouseButton1Click:Connect(function()
		music.Visible = not music.Visible
		keyManager.Visible = false
	end)
	managerClose.MouseButton1Click:Connect(function() keyManager.Visible = false end)
	musicClose.MouseButton1Click:Connect(function() music.Visible = false end)

	function categoryapi:CreateBind()
		local optionapi = {Bind = mainapi.Keybind}

		function optionapi:SetBind(tab, mouse)
			tab = bindKeys(tab)
			mainapi.Keybind = #tab <= 0 and bindKeys(mainapi.Keybind, {'RightShift'}) or tab
			self.Bind = mainapi.Keybind
		end

		categoryapi.Options.Bind = optionapi
		return optionapi
	end

	for i, v in components do
		categoryapi['Create'..i] = function(self, optionsettings)
			return v(optionsettings, children, categoryapi)
		end
	end

	settingsbutton.MouseButton1Click:Connect(function()
		children.Visible = not children.Visible
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale + 12)
	end)

	categoryapi.Object = bar
	self.Categories.TopBar = categoryapi

	return categoryapi
end

function mainapi:CreateCategory(categorysettings)
	local categoryapi = {
		Type = 'Category',
		Expanded = false,
		Options = {}
	}

	local window = Instance.new('TextButton')
	window.Name = categorysettings.Name..'Category'
	window.Size = UDim2.fromOffset(categorysettings.WindowSize or 160, 40)
	window.Position = UDim2.fromOffset(categorysettings.Name == 'GUI' and 4 or 174, 68)
	window.BackgroundColor3 = uipallet.Main
	window.BackgroundTransparency = 0
	window.BorderSizePixel = 0
	window.AutoButtonColor = false
	window.Visible = categorysettings.Name == 'GUI'
	window.Text = ''
	window.Parent = clickgui
	addCorner(window, UDim.new(0, 6))
	makeDraggable(window)
	local iconshadow = Instance.new('ImageLabel')
	iconshadow.Name = 'Icon'
	iconshadow.Size = UDim2.fromOffset(26, 26)
	iconshadow.Position = UDim2.fromOffset(7, 7)
	iconshadow.BackgroundTransparency = 1
	iconshadow.Image = categorysettings.Icon
	iconshadow.ImageColor3 = uipallet.Accent
	iconshadow.ImageTransparency = 0
	iconshadow.Parent = window
	local icon = iconshadow:Clone()
	icon.Position = UDim2.fromOffset(6, 6)
	icon.ImageColor3 = uipallet.Text
	icon.ImageTransparency = 0
	icon.Visible = false
	icon.Parent = window
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.new(1, -70, 1, 0)
	title.Position = UDim2.fromOffset(39, 0)
	title.BackgroundTransparency = 1
	title.Text = categorysettings.Name
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = uipallet.Text
	title.TextSize = 17
	title.FontFace = uipallet.Font
	title.Parent = window
	local arrowbutton = Instance.new('TextButton')
	arrowbutton.Name = 'Arrow'
	arrowbutton.Size = UDim2.fromOffset(30, 40)
	arrowbutton.Position = UDim2.new(1, -30, 0, 0)
	arrowbutton.BackgroundTransparency = 1
	arrowbutton.Text = '+'
	arrowbutton.TextColor3 = uipallet.Text
	arrowbutton.TextSize = 17
	arrowbutton.FontFace = uipallet.Font
	arrowbutton.Parent = window
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, 0)
	children.Position = UDim2.fromScale(0, 1)
	children.BackgroundColor3 = window.BackgroundColor3
	children.BackgroundTransparency = categorysettings.Name == 'Settings' and 0.06 or 1
	children.BorderSizePixel = 0
	children.Visible = false
	children.ScrollBarThickness = 0
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = window
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Left
	windowlist.Parent = children

	function categoryapi:CreateModule(modulesettings)
		mainapi:Remove(modulesettings.Name)
		local moduleapi = {
			Enabled = false,
			Options = {},
			Bind = {},
			Index = modulesettings.Index or getTableSize(mainapi.Modules),
			ExtraText = modulesettings.ExtraText,
			Name = modulesettings.Name,
			Category = categorysettings.Name
		}

		local modulebutton = Instance.new('TextButton')
		modulebutton.Name = modulesettings.Name
		modulebutton.Size = UDim2.new(1, -16, 0, 30)
		modulebutton.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
		modulebutton.BackgroundTransparency = 0.06
		modulebutton.BorderSizePixel = 0
		modulebutton.AutoButtonColor = false
		modulebutton.Text = modulesettings.Name
		modulebutton.TextColor3 = uipallet.Text
		modulebutton.TextSize = 17
		modulebutton.FontFace = uipallet.Font
		modulebutton.Parent = children
		local gradient = Instance.new('UIGradient')
		gradient.Rotation = 90
		gradient.Enabled = false
		gradient.Parent = modulebutton
		local hover = Instance.new('Frame')
		hover.Size = UDim2.fromScale(1, 1)
		hover.BackgroundColor3 = Color3.new()
		hover.BackgroundTransparency = 0.9
		hover.BorderSizePixel = 0
		hover.Visible = false
		hover.Parent = modulebutton
		local modulechildren = Instance.new('Frame')
		local dotsbutton = Instance.new('TextButton')
		addTooltip(modulebutton, modulesettings.Tooltip)
		dotsbutton.Name = 'Dots'
		dotsbutton.Size = UDim2.fromOffset(16, 30)
		dotsbutton.Position = UDim2.fromScale(1, 0)
		dotsbutton.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		dotsbutton.BackgroundTransparency = 0.06
		dotsbutton.BorderSizePixel = 0
		dotsbutton.AutoButtonColor = false
		dotsbutton.Text = ''
		dotsbutton.TextColor3 = uipallet.Text
		dotsbutton.TextSize = 17
		dotsbutton.FontFace = uipallet.Font
		dotsbutton.LineHeight = 0.3
		dotsbutton.Parent = modulebutton
		modulechildren.Name = modulesettings.Name..'Children'
		modulechildren.Size = UDim2.new(1, 0, 0, 0)
		modulechildren.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		modulechildren.BackgroundTransparency = 0.06
		modulechildren.BorderSizePixel = 0
		modulechildren.Visible = false
		modulechildren.Parent = children
		moduleapi.Children = modulechildren
		local windowlist = Instance.new('UIListLayout')
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.Parent = modulechildren
		modulesettings.Function = modulesettings.Function or function() end
		if modulesettings.Special then
			modulebutton.Size = UDim2.new(1, 0, 0, 30)
			dotsbutton.Visible = false
		end
		addMaid(moduleapi)

		function moduleapi:SetBind(tab, mouse)
			tab = type(tab) == 'table' and tab or {}
			local mobile = type(tab.Mobile) == 'table' and tab.Mobile or tab.Mobile == true and tab
			if mobile and type(mobile.X) == 'number' and type(mobile.Y) == 'number' then
				createMobileButton(moduleapi, Vector2.new(mobile.X, mobile.Y))
				return
			end

			tab = bindKeys(tab)
			self.Bind = table.clone(tab)
			if mouse then
				modulebutton.Text = #tab <= 0 and 'Unbound' or 'Bound to '..table.concat(tab, ' + '):upper()
				task.delay(1, function()
					modulebutton.Text = modulesettings.Name
				end)
			end
		end

		function moduleapi:Toggle(multiple)
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			self.Enabled = not self.Enabled
			gradient.Enabled = self.Enabled
			modulebutton.TextColor3 = uipallet.Text
			modulebutton.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
			modulebutton.BackgroundTransparency = self.Enabled and 0 or 0.06
			if not self.Enabled then
				for _, v in self.Connections do
					v:Disconnect()
				end
				table.clear(self.Connections)
			end
			if not multiple then
				mainapi:UpdateTextGUI()
			end
			task.spawn(modulesettings.Function, self.Enabled)
		end

		for i, v in components do
			moduleapi['Create'..i] = function(self, optionsettings)
				dotsbutton.Text = '·\n·\n·'
				return v(optionsettings, modulechildren, moduleapi)
			end
		end

		dotsbutton.MouseButton1Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
			dotsbutton.BackgroundColor3 = modulechildren.Visible and color.Dark(children.BackgroundColor3, 0.05) or color.Light(uipallet.Main, 0.02)
		end)
		dotsbutton.MouseButton2Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
			dotsbutton.BackgroundColor3 = modulechildren.Visible and color.Dark(children.BackgroundColor3, 0.05) or color.Light(uipallet.Main, 0.02)
		end)
		modulebutton.MouseEnter:Connect(function()
			hover.Visible = true
		end)
		modulebutton.MouseLeave:Connect(function()
			hover.Visible = false
		end)
		modulebutton.MouseButton1Click:Connect(function()
			if inputService:IsKeyDown(Enum.KeyCode.LeftShift) and not modulesettings.Special then
				modulebutton.Text = 'Press a key'
				mainapi.Binding = moduleapi
				return
			end
			moduleapi:Toggle()
		end)
		modulebutton.MouseButton2Click:Connect(function()
			modulechildren.Visible = not modulechildren.Visible
			dotsbutton.BackgroundColor3 = modulechildren.Visible and color.Dark(children.BackgroundColor3, 0.05) or color.Light(uipallet.Main, 0.02)
		end)
		if inputService.TouchEnabled then
			local heldbutton = false
			modulebutton.MouseButton1Down:Connect(function()
				heldbutton = true
				local holdtime, holdpos = tick(), inputService:GetMouseLocation()
				repeat
					heldbutton = (inputService:GetMouseLocation() - holdpos).Magnitude < 3
					task.wait()
				until (tick() - holdtime) > 1 or not heldbutton or not clickgui.Visible
				if heldbutton and clickgui.Visible then
					if mainapi.ThreadFix then
						setthreadidentity(8)
					end
					clickgui.Visible = false
					tooltip.Visible = false
					mainapi:BlurCheck()

					for _, mobileButton in mainapi.Modules do
						if mobileButton.Bind.Button then
							mobileButton.Bind.Button.Visible = true
						end
					end

					local touchconnection
					touchconnection = inputService.InputBegan:Connect(function(inputType)
						if inputType.UserInputType == Enum.UserInputType.Touch then
							if mainapi.ThreadFix then
								setthreadidentity(8)
							end
							createMobileButton(moduleapi, inputType.Position + Vector3.new(0, guiService:GetGuiInset().Y, 0))
							clickgui.Visible = true
							mainapi:BlurCheck()
							for _, mobileButton in mainapi.Modules do
								if mobileButton.Bind.Button then
									mobileButton.Bind.Button.Visible = false
								end
							end
							touchconnection:Disconnect()
						end
					end)
				end
			end)
			modulebutton.MouseButton1Up:Connect(function()
				heldbutton = false
			end)
		end
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			modulechildren.Size = UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		end)

		moduleapi.Object = modulebutton
		mainapi.Modules[modulesettings.Name] = moduleapi

		local sorting = {}
		for _, v in mainapi.Modules do
			if v.Category == 'GUI' then continue end
			sorting[v.Category] = sorting[v.Category] or {}
			table.insert(sorting[v.Category], v.Name)
		end

		for _, sort in sorting do
			table.sort(sort)
			for i, v in sort do
				mainapi.Modules[v].Index = i
				mainapi.Modules[v].Object.LayoutOrder = i
				mainapi.Modules[v].Children.LayoutOrder = i
			end
		end

		if modulesettings.Special then
			local num = 0
			for i in mainapi.Categories do
				if i ~= 'Main' and i ~= 'TopBar' then
					num += 1
				end
			end
			moduleapi.Index = num
		end

		return moduleapi
	end

	function categoryapi:Expand()
		self.Expanded = not self.Expanded
		children.Visible = self.Expanded
		arrowbutton.Text = self.Expanded and '-' or '+'
	end

	for i, v in components do
		categoryapi['Create'..i] = function(self, optionsettings)
			return v(optionsettings, children, categoryapi)
		end
	end

	arrowbutton.MouseButton1Click:Connect(function()
		categoryapi:Expand()
	end)
	arrowbutton.MouseButton2Click:Connect(function()
		categoryapi:Expand()
	end)
	window.MouseButton2Click:Connect(function(inputObj)
		categoryapi:Expand()
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		children.Size = UDim2.new(1, 0, 0, math.min(windowlist.AbsoluteContentSize.Y / scale.Scale, 600))
	end)

	if categorysettings.Name == 'GUI' then
		self.Categories.Main = categoryapi
	else
		categoryapi.Button = self.Categories.Main:CreateModule({
			Name = categorysettings.Name,
			Function = function(callback)
				window.Visible = callback
			end,
			Special = true
		})
		self.Categories[categorysettings.Name] = categoryapi
	end
	categoryapi.Object = window

	return categoryapi
end

function mainapi:CreateLegit(categorysettings)
	local categoryapi = {
		Type = 'Category',
		Expanded = false,
		Modules = {}
	}

	local window = Instance.new('TextButton')
	window.Name = categorysettings.Name..'Category'
	window.Size = UDim2.fromOffset(160, 40)
	window.Position = UDim2.fromOffset(174, 68)
	window.BackgroundColor3 = uipallet.Main
	window.BackgroundTransparency = 0.06
	window.BorderSizePixel = 0
	window.AutoButtonColor = false
	window.Visible = false
	window.Text = ''
	window.Parent = clickgui
	makeDraggable(window)
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Text = categorysettings.Name
	title.TextColor3 = uipallet.Text
	title.TextSize = 17
	title.FontFace = uipallet.Font
	title.Parent = window
	local arrowbutton = Instance.new('TextButton')
	arrowbutton.Name = 'Arrow'
	arrowbutton.Size = UDim2.fromOffset(30, 40)
	arrowbutton.Position = UDim2.new(1, -30, 0, 0)
	arrowbutton.BackgroundTransparency = 1
	arrowbutton.Text = '+'
	arrowbutton.TextColor3 = uipallet.Text
	arrowbutton.TextSize = 17
	arrowbutton.FontFace = uipallet.Font
	arrowbutton.Parent = window
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, 0)
	children.Position = UDim2.fromScale(0, 1)
	children.BackgroundColor3 = window.BackgroundColor3
	children.BackgroundTransparency = categorysettings.Name == 'Settings' and 0.06 or 1
	children.BorderSizePixel = 0
	children.Visible = false
	children.ScrollBarThickness = 0
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = window
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Left
	windowlist.Parent = children

	function categoryapi:CreateModule(modulesettings)
		local moduleapi = {
			Enabled = false,
			Options = {},
			Index = modulesettings.Index or getTableSize(mainapi.Modules),
			ExtraText = modulesettings.ExtraText,
			Name = modulesettings.Name,
			Category = categorysettings.Name
		}
		mainapi:Remove(modulesettings.Name)

		local modulebutton = Instance.new('TextButton')
		modulebutton.Name = modulesettings.Name
		modulebutton.Size = UDim2.new(1, -16, 0, 30)
		modulebutton.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
		modulebutton.BackgroundTransparency = 0.06
		modulebutton.BorderSizePixel = 0
		modulebutton.AutoButtonColor = false
		modulebutton.Text = modulesettings.Name
		modulebutton.TextColor3 = uipallet.Text
		modulebutton.TextSize = 17
		modulebutton.FontFace = uipallet.Font
		modulebutton.Parent = children
		local gradient = Instance.new('UIGradient')
		gradient.Rotation = 90
		gradient.Enabled = false
		gradient.Parent = modulebutton
		local hover = Instance.new('Frame')
		hover.Size = UDim2.fromScale(1, 1)
		hover.BackgroundColor3 = Color3.new()
		hover.BackgroundTransparency = 0.9
		hover.BorderSizePixel = 0
		hover.Visible = false
		hover.Parent = modulebutton
		local settingschildren = Instance.new('Frame')
		local dotsbutton = Instance.new('TextButton')
		dotsbutton.Name = 'Dots'
		dotsbutton.Size = UDim2.fromOffset(16, 30)
		dotsbutton.Position = UDim2.fromScale(1, 0)
		dotsbutton.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		dotsbutton.BackgroundTransparency = 0.06
		dotsbutton.BorderSizePixel = 0
		dotsbutton.AutoButtonColor = false
		dotsbutton.Text = ''
		dotsbutton.TextColor3 = uipallet.Text
		dotsbutton.TextSize = 17
		dotsbutton.FontFace = uipallet.Font
		dotsbutton.LineHeight = 0.3
		dotsbutton.Parent = modulebutton
		settingschildren.Name = modulesettings.Name..'Children'
		settingschildren.Size = UDim2.new(1, 0, 0, 0)
		settingschildren.BackgroundColor3 = color.Light(uipallet.Main, 0.02)
		settingschildren.BackgroundTransparency = 0.06
		settingschildren.BorderSizePixel = 0
		settingschildren.Visible = false
		settingschildren.Parent = children
		moduleapi.Settings = settingschildren
		local windowlist = Instance.new('UIListLayout')
		windowlist.SortOrder = Enum.SortOrder.LayoutOrder
		windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		windowlist.Parent = settingschildren
		if modulesettings.Size then
			local moduleholder = Instance.new('Frame')
			moduleholder.Size = modulesettings.Size
			moduleholder.BackgroundTransparency = 1
			moduleholder.Visible = false
			moduleholder.Parent = scaledgui
			makeDraggable(moduleholder, window)
			local objectstroke = Instance.new('UIStroke')
			objectstroke.Color = Color3.fromRGB(5, 134, 105)
			objectstroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			objectstroke.Thickness = 0
			objectstroke.Parent = moduleholder
			moduleapi.Children = moduleholder
		end
		modulesettings.Function = modulesettings.Function or function() end
		addMaid(moduleapi)

		function moduleapi:Toggle(multiple)
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			moduleapi.Enabled = not moduleapi.Enabled
			if moduleapi.Children then
				moduleapi.Children.Visible = moduleapi.Enabled
			end
			gradient.Enabled = moduleapi.Enabled
			modulebutton.TextColor3 = uipallet.Text
			modulebutton.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
			modulebutton.BackgroundTransparency = moduleapi.Enabled and 0 or 0.06
			if not moduleapi.Enabled then
				for _, v in moduleapi.Connections do
					v:Disconnect()
				end
				table.clear(moduleapi.Connections)
			end
			if not multiple then
				mainapi:UpdateTextGUI()
			end
			task.spawn(modulesettings.Function, moduleapi.Enabled)
		end

		for i, v in components do
			moduleapi['Create'..i] = function(self, optionsettings)
				dotsbutton.Text = '·\n·\n·'
				return v(optionsettings, settingschildren, moduleapi)
			end
		end

		dotsbutton.MouseButton1Click:Connect(function()
			settingschildren.Visible = not settingschildren.Visible
			dotsbutton.BackgroundColor3 = settingschildren.Visible and color.Dark(children.BackgroundColor3, 0.05) or color.Light(uipallet.Main, 0.02)
		end)
		dotsbutton.MouseButton2Click:Connect(function()
			settingschildren.Visible = not settingschildren.Visible
			dotsbutton.BackgroundColor3 = settingschildren.Visible and color.Dark(children.BackgroundColor3, 0.05) or color.Light(uipallet.Main, 0.02)
		end)
		modulebutton.MouseEnter:Connect(function()
			hover.Visible = true
		end)
		modulebutton.MouseLeave:Connect(function()
			hover.Visible = false
		end)
		modulebutton.MouseButton1Click:Connect(function()
			moduleapi:Toggle()
		end)
		modulebutton.MouseButton2Click:Connect(function()
			settingschildren.Visible = not settingschildren.Visible
			dotsbutton.BackgroundColor3 = settingschildren.Visible and color.Dark(children.BackgroundColor3, 0.05) or color.Light(uipallet.Main, 0.02)
		end)
		windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			settingschildren.Size = UDim2.new(1, 0, 0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		end)

		moduleapi.Object = modulebutton
		categoryapi.Modules[modulesettings.Name] = moduleapi

		local sorting = {}
		for _, v in categoryapi.Modules do
			sorting[v.Category] = sorting[v.Category] or {}
			table.insert(sorting[v.Category], v.Name)
		end

		for _, sort in sorting do
			table.sort(sort)
			for i, v in sort do
				categoryapi.Modules[v].Index = i
				categoryapi.Modules[v].Object.LayoutOrder = i
				categoryapi.Modules[v].Settings.LayoutOrder = i
			end
		end

		return moduleapi
	end

	function categoryapi:Expand()
		self.Expanded = not self.Expanded
		children.Visible = self.Expanded
		arrowbutton.Text = self.Expanded and '-' or '+'
	end

	for i, v in components do
		categoryapi['Create'..i] = function(self, optionsettings)
			return v(optionsettings, children, categoryapi)
		end
	end

	arrowbutton.MouseButton1Click:Connect(function()
		categoryapi:Expand()
	end)
	arrowbutton.MouseButton2Click:Connect(function()
		categoryapi:Expand()
	end)
	window.MouseButton2Click:Connect(function(inputObj)
		categoryapi:Expand()
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		children.Size = UDim2.new(1, 0, 0, math.min(windowlist.AbsoluteContentSize.Y / scale.Scale, 600))
	end)

	categoryapi.Button = self.Categories.Main:CreateModule({
		Name = categorysettings.Name,
		Function = function(callback)
			window.Visible = callback
		end,
		Special = true
	})
	self.Categories[categorysettings.Name] = categoryapi
	categoryapi.Object = window

	return categoryapi
end

function mainapi:CreateOverlay(categorysettings)
	local window
	local categoryapi
	categoryapi = {
		Type = 'Overlay',
		Expanded = false,
		Button = self.Categories.Main:CreateModule({
			Name = categorysettings.Name,
			Function = function(callback)
				window.Visible = callback and (clickgui.Visible or categoryapi.Pinned)
				if not callback then
					for _, v in categoryapi.Connections do
						v:Disconnect()
					end
					table.clear(categoryapi.Connections)
				end

				if categorysettings.Function then
					task.spawn(categorysettings.Function, callback)
				end
			end,
			Special = true
		}),
		Pinned = false,
		Options = {}
	}
	categoryapi.Options = categoryapi.Button.Options

	window = Instance.new('TextButton')
	window.Name = categorysettings.Name..'Overlay'
	window.Size = UDim2.fromOffset(categorysettings.WindowSize or 178, 40)
	window.Position = UDim2.fromOffset(174, 68)
	window.BackgroundColor3 = uipallet.Main
	window.BackgroundTransparency = 0.06
	window.BorderSizePixel = 0
	window.AutoButtonColor = false
	window.Text = ''
	window.Parent = scaledgui
	makeDraggable(window)
	local iconshadow = Instance.new('ImageLabel')
	iconshadow.Name = 'Icon'
	iconshadow.Size = UDim2.fromOffset(26, 26)
	iconshadow.Position = UDim2.fromOffset(7, 7)
	iconshadow.BackgroundTransparency = 1
	iconshadow.Image = categorysettings.Icon
	iconshadow.ImageColor3 = Color3.new()
	iconshadow.ImageTransparency = 0.5
	iconshadow.Parent = window
	local icon = iconshadow:Clone()
	icon.Position = UDim2.fromOffset(6, 6)
	icon.ImageColor3 = uipallet.Text
	icon.ImageTransparency = 0
	icon.Parent = window
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Text = categorysettings.Name
	title.TextColor3 = uipallet.Text
	title.TextSize = 17
	title.FontFace = uipallet.Font
	title.Parent = window
	local pin = Instance.new('ImageButton')
	pin.Name = 'Pin'
	pin.Size = UDim2.fromOffset(18, 18)
	pin.Position = UDim2.new(1, -23, 0, 11)
	pin.BackgroundTransparency = 1
	pin.AutoButtonColor = false
	pin.Image = getcustomasset('newvape/assets/jello/pin.png')
	pin.ImageColor3 = color.Dark(uipallet.Text, 0.43)
	pin.Parent = window
	local customchildren = Instance.new('Frame')
	customchildren.Name = 'CustomChildren'
	customchildren.Size = UDim2.new(1, 0, 0, 200)
	customchildren.Position = UDim2.fromScale(0, 1)
	customchildren.BackgroundTransparency = 1
	customchildren.Parent = window
	categoryapi.Button.OriginalChildren = categoryapi.Button.Children
	categoryapi.Button.Children = customchildren
	categoryapi.Button.Button = categoryapi.Button
	addMaid(categoryapi)

	function categoryapi:Pin()
		self.Pinned = not self.Pinned
		pin.ImageColor3 = self.Pinned and uipallet.Text or color.Dark(uipallet.Text, 0.43)
	end

	function categoryapi:Update()
		window.Visible = self.Button.Enabled and (clickgui.Visible or self.Pinned)
		if self.Expanded then
			self:Expand()
		end

		if clickgui.Visible then
			window.Size = UDim2.fromOffset(window.Size.X.Offset, 40)
			window.BackgroundTransparency = 0.06
			icon.Visible = true
			iconshadow.Visible = true
			title.Visible = true
			pin.Visible = true
		else
			window.Size = UDim2.fromOffset(window.Size.X.Offset, 0)
			window.BackgroundTransparency = 1
			icon.Visible = false
			iconshadow.Visible = false
			title.Visible = false
			pin.Visible = false
		end
	end

	categoryapi.Button.OriginalChildren.UIListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		categoryapi.Button.Object.Size = UDim2.new(1, -16, 0, 30)
		categoryapi.Button.Object.Dots.Visible = true
	end)
	pin.MouseButton1Click:Connect(function()
		categoryapi:Pin()
	end)
	window.MouseButton2Click:Connect(function()
		categoryapi:Pin()
	end)
	self:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
		categoryapi:Update()
	end))

	categoryapi:Update()
	categoryapi.Object = window
	categoryapi.Children = customchildren
	self.Categories[categorysettings.Name] = categoryapi

	return categoryapi.Button
end

function mainapi:CreateCategoryList(categorysettings)
	local categoryapi = {
		Type = 'CategoryList',
		Expanded = false,
		List = {},
		ListEnabled = {},
		Objects = {},
		Options = {}
	}

	local window = Instance.new('TextButton')
	window.Name = categorysettings.Name..'CategoryList'
	window.Size = UDim2.fromOffset(categorysettings.WindowSize or 160, 40)
	window.Position = UDim2.fromOffset(174, 68)
	window.BackgroundColor3 = uipallet.Main
	window.BackgroundTransparency = 0.06
	window.BorderSizePixel = 0
	window.AutoButtonColor = false
	window.Visible = false
	window.Text = ''
	window.Parent = clickgui
	makeDraggable(window)
	local iconshadow = Instance.new('ImageLabel')
	iconshadow.Name = 'Icon'
	iconshadow.Size = UDim2.fromOffset(26, 26)
	iconshadow.Position = UDim2.fromOffset(7, 7)
	iconshadow.BackgroundTransparency = 1
	iconshadow.Image = categorysettings.Icon
	iconshadow.ImageColor3 = Color3.new()
	iconshadow.ImageTransparency = 0.5
	iconshadow.Parent = window
	local icon = iconshadow:Clone()
	icon.Position = UDim2.fromOffset(6, 6)
	icon.ImageColor3 = uipallet.Text
	icon.ImageTransparency = 0
	icon.Parent = window
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.fromScale(1, 1)
	title.BackgroundTransparency = 1
	title.Text = categorysettings.Name
	title.TextColor3 = uipallet.Text
	title.TextSize = 17
	title.FontFace = uipallet.Font
	title.Parent = window
	local arrowbutton = Instance.new('TextButton')
	arrowbutton.Name = 'Arrow'
	arrowbutton.Size = UDim2.fromOffset(30, 40)
	arrowbutton.Position = UDim2.new(1, -30, 0, 0)
	arrowbutton.BackgroundTransparency = 1
	arrowbutton.Text = '+'
	arrowbutton.TextColor3 = uipallet.Text
	arrowbutton.TextSize = 17
	arrowbutton.FontFace = uipallet.Font
	arrowbutton.Parent = window
	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, 0)
	children.Position = UDim2.fromScale(0, 1)
	children.BackgroundColor3 = window.BackgroundColor3
	children.BackgroundTransparency = 0.06
	children.BorderSizePixel = 0
	children.Visible = false
	children.ScrollBarThickness = 0
	children.ScrollBarImageTransparency = 0.75
	children.CanvasSize = UDim2.new()
	children.Parent = window
	addCorner(children, UDim.new(0, 6))
	local childrentwo = Instance.new('Frame')
	childrentwo.BackgroundTransparency = 1
	childrentwo.BackgroundColor3 = window.BackgroundColor3
	childrentwo.Parent = children
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Left
	windowlist.Padding = UDim.new(0, 3)
	windowlist.Parent = children
	local windowlisttwo = Instance.new('UIListLayout')
	windowlisttwo.SortOrder = Enum.SortOrder.LayoutOrder
	windowlisttwo.HorizontalAlignment = Enum.HorizontalAlignment.Left
	windowlisttwo.Parent = childrentwo
	local addbkg = Instance.new('Frame')
	addbkg.Name = 'Add'
	addbkg.Size = UDim2.new(1, 0, 0, 32)
	addbkg.Position = UDim2.fromOffset(10, 45)
	addbkg.BackgroundTransparency = 1
	addbkg.BorderSizePixel = 0
	addbkg.Parent = children
	local addbox = addbkg:Clone()
	addbox.Size = UDim2.new(1, -50, 1, -8)
	addbox.Position = UDim2.fromOffset(4, 4)
	addbox.BackgroundColor3 = Color3.fromRGB(238, 238, 238)
	addbox.BackgroundTransparency = 0
	addbox.Parent = addbkg
	addCorner(addbox, UDim.new(0, 4))
	local addvalue = Instance.new('TextBox')
	addvalue.Size = UDim2.new(1, -35, 1, 0)
	addvalue.Position = UDim2.fromOffset(10, 0)
	addvalue.BackgroundTransparency = 1
	addvalue.Text = ''
	addvalue.PlaceholderText = categorysettings.Placeholder or 'Add entry...'
	addvalue.TextXAlignment = Enum.TextXAlignment.Left
	addvalue.PlaceholderColor3 = uipallet.Muted
	addvalue.TextColor3 = uipallet.Text
	addvalue.TextSize = 15
	addvalue.FontFace = uipallet.Font
	addvalue.ClearTextOnFocus = false
	addvalue.Parent = addbox
	local addbutton = Instance.new('TextButton')
	addbutton.Name = 'AddButton'
	addbutton.Size = UDim2.new(0, 44, 1, -8)
	addbutton.Position = UDim2.new(1, -46, 0, 4)
	addbutton.BackgroundTransparency = 1
	addbutton.Text = 'Add'
	addbutton.TextColor3 = uipallet.Text
	addbutton.TextSize = 18
	addbutton.FontFace = uipallet.Font
	addbutton.Parent = addbkg
	categoryapi.Profiles = categorysettings.Profiles
	categorysettings.Function = categorysettings.Function or function() end

	function categoryapi:ChangeValue(val)
		if val then
			if categorysettings.Profiles then
				local ind = self:GetValue(val)
				if ind then
					if val ~= 'default' then
						table.remove(mainapi.Profiles, ind)
						if isfile('newvape/profiles/'..val..mainapi.Place..'.txt') and delfile then
							delfile('newvape/profiles/'..val..mainapi.Place..'.txt')
						end
					end
				else
					table.insert(mainapi.Profiles, {Name = val, Bind = {}})
				end
			else
				local ind = table.find(self.List, val)
				if ind then
					table.remove(self.List, ind)
					ind = table.find(self.ListEnabled, val)
					if ind then
						table.remove(self.ListEnabled, ind)
					end
				else
					table.insert(self.List, val)
					table.insert(self.ListEnabled, val)
				end
			end
		end

		categorysettings.Function()
		for _, v in self.Objects do
			v:Destroy()
		end
		table.clear(self.Objects)
		self.Selected = nil

		for i, v in (categorysettings.Profiles and mainapi.Profiles or self.List) do
			if categorysettings.Profiles then
				local object = Instance.new('TextButton')
				object.Name = v.Name
				object.Size = UDim2.new(1, -14, 0, 20)
				object.BackgroundTransparency = 1
				object.Text = ''
				object.Parent = children
				local objectbkg = Instance.new('Frame')
				objectbkg.Name = 'BKG'
				objectbkg.Size = UDim2.new(1, -30, 1, 0)
				objectbkg.Position = UDim2.fromOffset(4, 0)
				objectbkg.BackgroundColor3 = Color3.fromRGB(247, 247, 247)
				objectbkg.BorderSizePixel = 0
				objectbkg.Visible = true
				objectbkg.Parent = object
				local objecttitle = Instance.new('TextLabel')
				objecttitle.Name = 'Title'
				objecttitle.Size = UDim2.new(1, -8, 1, 0)
				objecttitle.Position = UDim2.fromOffset(8, 0)
				objecttitle.BackgroundTransparency = 1
				objecttitle.Text = v.Name
				objecttitle.TextXAlignment = Enum.TextXAlignment.Left
				objecttitle.TextColor3 = uipallet.Text
				objecttitle.TextSize = 18
				objecttitle.FontFace = uipallet.Font
				objecttitle.Parent = object
				if mainapi.ThreadFix then
					setthreadidentity(8)
				end
				local close = Instance.new('TextButton')
				close.Name = 'Close'
				close.Size = UDim2.fromOffset(20, 20)
				close.Position = UDim2.new(1, -24, 0, 0)
				close.BackgroundColor3 = objectbkg.BackgroundColor3
				close.BorderSizePixel = 0
				close.AutoButtonColor = false
				close.Text = 'x'
				close.TextColor3 = uipallet.Text
				close.TextSize = 14
				close.FontFace = uipallet.Font
				close.Parent = object
				close.MouseButton1Click:Connect(function()
					if v.Name ~= mainapi.Profile then
						self:ChangeValue(v.Name)
					end
				end)

				local function bindFunction(self, tab, mouse)
					v.Bind = table.clone(tab)
					if mouse then
						objecttitle.Text = #tab <= 0 and 'Unbound' or 'Bound to '..table.concat(tab, ' + '):upper()
						task.delay(1, function()
							objecttitle.Text = v.Name
						end)
					end
				end

				bindFunction({}, v.Bind)
				object.MouseButton1Click:Connect(function()
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						objecttitle.Text = 'Press a key'
						mainapi.Binding = {SetBind = bindFunction, Bind = v.Bind}
						return
					end
					mainapi:Save(v.Name)
					mainapi:Load(true)
				end)
				if v.Name == mainapi.Profile then
					self.Selected = object
				end
				table.insert(self.Objects, object)
			else
				local enabled = table.find(self.ListEnabled, v)
				local object = Instance.new('TextButton')
				object.Name = v
				object.Size = UDim2.new(1, -14, 0, 24)
				object.BackgroundTransparency = 1
				object.Text = ''
				object.Parent = children
				local objectbkg = Instance.new('Frame')
				objectbkg.Name = 'BKG'
				objectbkg.Size = UDim2.new(1, -30, 1, 0)
				objectbkg.Position = UDim2.fromOffset(4, 0)
				objectbkg.BackgroundColor3 = Color3.fromRGB(247, 247, 247)
				objectbkg.BorderSizePixel = 0
				objectbkg.Visible = true
				objectbkg.Parent = object
				local objectdot = Instance.new('Frame')
				objectdot.Name = 'Dot'
				objectdot.Size = UDim2.fromOffset(16, 16)
				objectdot.Position = UDim2.fromOffset(8, 4)
				objectdot.BackgroundColor3 = enabled and uipallet.Accent or Color3.fromRGB(211, 211, 211)
				objectdot.BorderSizePixel = 0
				objectdot.Parent = object
				local objectdotin = Instance.new('ImageLabel')
				objectdotin.Size = UDim2.fromScale(1, 1)
				objectdotin.BackgroundTransparency = 1
				objectdotin.Image = getcustomasset('newvape/assets/jello/checkbox.png')
				objectdotin.ImageColor3 = uipallet.Text
				objectdotin.Visible = enabled and true or false
				objectdotin.Parent = objectdot
				local objecttitle = Instance.new('TextLabel')
				objecttitle.Name = 'Title'
				objecttitle.Size = UDim2.new(1, -28, 1, 0)
				objecttitle.Position = UDim2.fromOffset(28, 0)
				objecttitle.BackgroundTransparency = 1
				objecttitle.Text = v
				objecttitle.TextXAlignment = Enum.TextXAlignment.Left
				objecttitle.TextColor3 = uipallet.Text
				objecttitle.TextSize = 18
				objecttitle.FontFace = uipallet.Font
				objecttitle.Parent = object
				if mainapi.ThreadFix then
					setthreadidentity(8)
				end
				local close = Instance.new('TextButton')
				close.Name = 'Close'
				close.Size = UDim2.fromOffset(24, 24)
				close.Position = UDim2.new(1, -24, 0, 0)
				close.BackgroundColor3 = objectbkg.BackgroundColor3
				close.BorderSizePixel = 0
				close.AutoButtonColor = false
				close.Text = 'x'
				close.TextColor3 = uipallet.Text
				close.TextSize = 14
				close.FontFace = uipallet.Font
				close.Parent = object
				close.MouseButton1Click:Connect(function()
					self:ChangeValue(v)
				end)
				object.MouseButton1Click:Connect(function()
					local ind = table.find(self.ListEnabled, v)
					if ind then
						table.remove(self.ListEnabled, ind)
						objectdotin.Visible = false
						objectdot.BackgroundColor3 = Color3.fromRGB(211, 211, 211)
					else
						table.insert(self.ListEnabled, v)
						objectdotin.Visible = true
						objectdot.BackgroundColor3 = uipallet.Accent
					end
					categorysettings.Function()
				end)
				table.insert(self.Objects, object)
			end
			mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value)
		end
	end

	function categoryapi:Expand()
		self.Expanded = not self.Expanded
		children.Visible = self.Expanded
		arrowbutton.Text = self.Expanded and '-' or '+'
	end

	function categoryapi:GetValue(name)
		for i, v in mainapi.Profiles do
			if v.Name == name then
				return i
			end
		end
	end

	for i, v in components do
		categoryapi['Create'..i] = function(self, optionsettings)
			return v(optionsettings, childrentwo, categoryapi)
		end
	end

	addbutton.MouseButton1Click:Connect(function()
		if not table.find(categoryapi.List, addvalue.Text) then
			categoryapi:ChangeValue(addvalue.Text)
			addvalue.Text = ''
		end
	end)
	arrowbutton.MouseButton1Click:Connect(function()
		categoryapi:Expand()
	end)
	arrowbutton.MouseButton2Click:Connect(function()
		categoryapi:Expand()
	end)
	addvalue.FocusLost:Connect(function(enter)
		if enter and not table.find(categoryapi.List, addvalue.Text) then
			categoryapi:ChangeValue(addvalue.Text)
			addvalue.Text = ''
		end
	end)
	window.MouseButton2Click:Connect(function(inputObj)
		categoryapi:Expand()
	end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		children.Size = UDim2.new(1, 0, 0, math.min((windowlist.AbsoluteContentSize.Y + 6) / scale.Scale, 606))
	end)
	windowlisttwo:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		childrentwo.Size = UDim2.new(1, 0, 0, windowlisttwo.AbsoluteContentSize.Y)
	end)

	categoryapi.Button = self.Categories.Main:CreateModule({
		Name = categorysettings.Name,
		Function = function(callback)
			window.Visible = callback
		end,
		Special = true
	})
	categoryapi.Object = window
	self.Categories[categorysettings.Name] = categoryapi

	return categoryapi
end

function mainapi:CreateNotification(title, text, duration, type)
	if not self.Notifications.Enabled then return end
	task.delay(0, function()
		if self.ThreadFix then
			setthreadidentity(8)
		end
		local i = #notifications:GetChildren() + 1
		local notification = Instance.new('Frame')
		notification.Name = 'Notification'
		notification.Size = UDim2.fromOffset(getfontsize(removeTags(text), 18, uipallet.Font).X + 36, 41)
		notification.Position = UDim2.new(1, 0, 1, -(29 + (44 * i)))
		notification.ZIndex = 5
		notification.BackgroundColor3 = color.Dark(uipallet.Main, 0.1)
		notification.BackgroundTransparency = 0.5
		notification.BorderSizePixel = 0
		notification.Parent = notifications
		local iconshadow = Instance.new('ImageLabel')
		iconshadow.Name = 'Icon'
		iconshadow.Size = UDim2.fromOffset(32, 32)
		iconshadow.Position = UDim2.fromOffset(1, 3)
		iconshadow.ZIndex = 5
		iconshadow.BackgroundTransparency = 1
		iconshadow.Image = getcustomasset('newvape/assets/jello/info.png')
		iconshadow.ImageColor3 = Color3.new()
		iconshadow.ImageTransparency = 0.5
		iconshadow.Parent = notification
		local icon = iconshadow:Clone()
		icon.Position = UDim2.fromOffset(-1, -1)
		icon.ImageColor3 = Color3.new(1, 1, 1)
		icon.ImageTransparency = 0
		icon.Parent = iconshadow
		local titlelabel = Instance.new('TextLabel')
		titlelabel.Name = 'Title'
		titlelabel.Size = UDim2.new(1, -31, 0, 20)
		titlelabel.Position = UDim2.fromOffset(31, 0)
		titlelabel.ZIndex = 5
		titlelabel.BackgroundTransparency = 1
		titlelabel.Text = title
		titlelabel.TextXAlignment = Enum.TextXAlignment.Left
		titlelabel.TextYAlignment = Enum.TextYAlignment.Top
		titlelabel.TextColor3 = uipallet.Text
		titlelabel.TextSize = 18
		titlelabel.RichText = true
		titlelabel.FontFace = uipallet.Font
		titlelabel.Parent = notification
		local textshadow = titlelabel:Clone()
		textshadow.Name = 'Text'
		textshadow.Position = UDim2.fromOffset(32, 19)
		textshadow.Text = removeTags(text)
		textshadow.TextColor3 = Color3.new()
		textshadow.TextTransparency = 0.5
		textshadow.RichText = false
		textshadow.FontFace = uipallet.Font
		textshadow.Parent = notification
		local textlabel = textshadow:Clone()
		textlabel.Position = UDim2.fromOffset(-1, -1)
		textlabel.Text = text
		textlabel.TextColor3 = Color3.fromRGB(170, 170, 170)
		textlabel.TextTransparency = 0
		textlabel.RichText = true
		textlabel.Parent = textshadow
		local progress = Instance.new('Frame')
		progress.Name = 'Progress'
		progress.Size = UDim2.new(1, -13, 0, 2)
		progress.Position = UDim2.new(0, 0, 1, -2)
		progress.ZIndex = 5
		progress.BackgroundColor3 = type == 'alert' and Color3.fromRGB(250, 50, 56) or type == 'warning' and Color3.fromRGB(236, 129, 43) or Color3.fromRGB(220, 220, 220)
		progress.BorderSizePixel = 0
		progress.Parent = notification
		if tween.Tween then
			tween:Tween(notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				AnchorPoint = Vector2.new(1, 0)
			}, tween.tweenstwo)
			tween:Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Size = UDim2.fromOffset(0, 2)
			})
		end
		task.delay(duration, function()
			if tween.Tween then
				tween:Tween(notification, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
					AnchorPoint = Vector2.new(0, 0)
				}, tween.tweenstwo)
			end
			task.wait(0.2)
			notification:ClearAllChildren()
			notification:Destroy()
		end)
	end)
end

function mainapi:Load(skipgui, profile)
	if not skipgui then
		self.GUIColor:SetValue(nil, nil, nil, 4)
	end
	local guidata = {}
	local savecheck = true

	if isfile('newvape/profiles/'..game.GameId..'.gui.txt') then
		guidata = loadJson('newvape/profiles/'..game.GameId..'.gui.txt')
		if not guidata then
			guidata = {Categories = {}}
			self:CreateNotification('Vape', 'Failed to load GUI settings.', 10, 'alert')
			savecheck = false
		end

		if not skipgui then
			local mainSettings = type(guidata.Categories) == 'table' and guidata.Categories.Main
			mainSettings = type(mainSettings) == 'table' and mainSettings.Settings
			mainSettings = type(mainSettings) == 'table' and mainSettings.Settings
			self.Keybind = bindKeys(guidata.Keybind or (type(mainSettings) == 'table' and mainSettings['Rebind GUI']), self.Keybind)
			for i, v in (type(guidata.Categories) == 'table' and guidata.Categories or {}) do
				local object = self.Categories[i]
				if not object then continue end
				if object.Options and v.Options then
					self:LoadOptions(object, v.Options)
				end
				if object.Button and v.Enabled ~= nil and v.Enabled ~= object.Button.Enabled then
					object.Button:Toggle()
				end
				if v.Pinned then
					object:Pin()
				end
				if v.Expanded ~= nil and v.Expanded ~= object.Expanded then object:Expand() end
				if v.List and (#object.List > 0 or #v.List > 0) then
					object.List = v.List or {}
					object.ListEnabled = v.ListEnabled or {}
					object:ChangeValue()
				end
				if v.Position and i ~= 'TopBar' then
					object.Object.Position = UDim2.fromOffset(v.Position.X, v.Position.Y)
				end
			end
		end
	end

	self.Profile = profile or guidata.Profile or 'default'
	local savedProfiles = {}
	local nestedProfiles = type(guidata.Categories) == 'table' and guidata.Categories.Profiles
	nestedProfiles = type(nestedProfiles) == 'table' and nestedProfiles.List or {}
	for _, entry in (type(nestedProfiles) == 'table' and nestedProfiles or {}) do table.insert(savedProfiles, entry) end
	for _, entry in (type(guidata.Profiles) == 'table' and guidata.Profiles or {}) do table.insert(savedProfiles, entry) end
	self.Profiles = discoverProfiles(savedProfiles)
	self.Categories.Profiles:ChangeValue()

	local profilePath = getProfilePath(self.Profile)
	if profilePath then
		local savedata = loadJson(profilePath)
		if not savedata then
			savedata = {
				Categories = {},
				Modules = {},
				Legit = {}
			}
			self:CreateNotification('Vape', 'Failed to load '..self.Profile..' profile.', 10, 'alert')
			savecheck = false
		end

		savedata.Categories = type(savedata.Categories) == 'table' and savedata.Categories or {}
		savedata.Modules = type(savedata.Modules) == 'table' and savedata.Modules or {}
		savedata.Legit = type(savedata.Legit) == 'table' and savedata.Legit or {}
		self.ProfileCache[self.Profile] = savedata
		for i, v in savedata.Categories do
			local object = self.Categories[i]
			if not object then continue end
			if object.Options and v.Options then
				self:LoadOptions(object, v.Options)
			end
			if v.Pinned ~= object.Pinned then
				object:Pin()
			end
			if v.Expanded ~= nil and v.Expanded ~= object.Expanded then
				object:Expand()
			end
			if object.Button and (v.Enabled or false) ~= object.Button.Enabled then
				object.Button:Toggle()
			end
			if v.List and (#object.List > 0 or #v.List > 0) then
				object.List = v.List or {}
				object.ListEnabled = v.ListEnabled or {}
				object:ChangeValue()
			end
			if v.Position then
				object.Object.Position = UDim2.fromOffset(v.Position.X or 0, v.Position.Y or 0)
			end
		end

		for i, v in savedata.Modules do
			local object = self.Modules[i]
			if not object then continue end
			if object.Options and v.Options then
				self:LoadOptions(object, v.Options)
			end
			if v.Enabled ~= object.Enabled then
				if skipgui then
					if self.ToggleNotifications.Enabled then self:CreateNotification('Module Toggled', i.."<font color='#FFFFFF'> has been </font>"..(v.Enabled and "<font color='#5AFF5A'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>").."<font color='#FFFFFF'>!</font>", 0.75) end
				end
				object:Toggle(true)
			end
			object:SetBind(v.Bind or {})
		end

		for i, v in savedata.Legit do
			local object = self.Legit.Modules[i]
			if not object then continue end
			if object.Options and v.Options then
				self:LoadOptions(object, v.Options)
			end
			if object.Enabled ~= v.Enabled then
				object:Toggle()
			end
			if v.Position and object.Children then
				object.Children.Position = UDim2.fromOffset(v.Position.X, v.Position.Y)
			end
		end

		self:UpdateTextGUI(true)
	else
		self:Save()
	end

	if self.Downloader then
		self.Downloader:Destroy()
		self.Downloader = nil
	end
	self.Loaded = savecheck
	self.Categories.TopBar.Options.Bind:SetBind(self.Keybind)

	if inputService.TouchEnabled and #self.Keybind == 1 and self.Keybind[1] == 'RightShift' then
		local button = Instance.new('TextButton')
		button.Size = UDim2.fromOffset(32, 32)
		button.Position = UDim2.new(1, -90, 0, 4)
		button.BackgroundColor3 = Color3.new()
		button.Text = ''
		button.Parent = gui
		local image = Instance.new('ImageLabel')
		image.Size = UDim2.fromOffset(26, 26)
		image.Position = UDim2.fromOffset(3, 3)
		image.BackgroundTransparency = 1
		image.Image = getcustomasset('newvape/assets/jello/vape.png')
		image.Parent = button
		self.VapeButton = button
		button.MouseButton1Click:Connect(function()
			if self.ThreadFix then
				setthreadidentity(8)
			end
			for _, v in self.Windows do
				v.Visible = false
			end
			for _, mobileButton in self.Modules do
				if mobileButton.Bind.Button then
					mobileButton.Bind.Button.Visible = clickgui.Visible
				end
			end
			clickgui.Visible = not clickgui.Visible
			tooltip.Visible = false
			self:BlurCheck()
		end)
	end
end

function mainapi:LoadOptions(object, savedoptions)
	for i, v in (type(savedoptions) == 'table' and savedoptions or {}) do
		local option = object.Options[i]
		if not option then continue end
		option:Load(v)
	end
end

function mainapi:Remove(obj)
	local tab = (self.Modules[obj] and self.Modules or self.Legit.Modules[obj] and self.Legit.Modules or self.Categories)
	if tab and tab[obj] then
		local newobj = tab[obj]
		if self.ThreadFix then
			setthreadidentity(8)
		end

		for _, v in {'Object', 'Children', 'Toggle', 'Button'} do
			local childobj = typeof(newobj[v]) == 'table' and newobj[v].Object or newobj[v]
			if typeof(childobj) == 'Instance' then
				childobj:Destroy()
				childobj:ClearAllChildren()
			end
		end

		loopClean(newobj)
		tab[obj] = nil
	end
end

function mainapi:Save(newprofile)
	if not self.Loaded then return end
	local guiPath = 'newvape/profiles/'..game.GameId..'.gui.txt'
	local guidata = loadJson(guiPath) or {}
	guidata.Categories = type(guidata.Categories) == 'table' and guidata.Categories or {}
	guidata.Profile = newprofile or self.Profile
	guidata.Profiles = self.Profiles
	guidata.Keybind = self.Keybind
	local savedata = self.ProfileCache[self.Profile]
	savedata = type(savedata) == 'table' and savedata or {}
	savedata.Modules = type(savedata.Modules) == 'table' and savedata.Modules or {}
	savedata.Categories = type(savedata.Categories) == 'table' and savedata.Categories or {}
	savedata.Legit = type(savedata.Legit) == 'table' and savedata.Legit or {}

	for i, v in self.Categories do
		(v.Type ~= 'Category' and i ~= 'GUI' and savedata or guidata).Categories[i] = {
			Enabled = v.Button and v.Button.Enabled or nil,
			Expanded = v.Type ~= 'Overlay' and v.Expanded or nil,
			Pinned = v.Pinned,
			Position = {X = v.Object.Position.X.Offset, Y = v.Object.Position.Y.Offset},
			Options = mainapi:SaveOptions(v, v.Options),
			List = v.List,
			ListEnabled = v.ListEnabled
		}
	end

	for i, v in self.Modules do
		savedata.Modules[i] = {
			Enabled = v.Enabled,
			Bind = typeof(v.Bind) == 'Instance' and {Mobile = true, X = v.Bind.Position.X.Offset, Y = v.Bind.Position.Y.Offset} or v.Bind,
			Options = mainapi:SaveOptions(v, true)
		}
	end

	for i, v in self.Legit.Modules do
		savedata.Legit[i] = {
			Enabled = v.Enabled,
			Position = v.Children and {X = v.Children.Position.X.Offset, Y = v.Children.Position.Y.Offset} or nil,
			Options = mainapi:SaveOptions(v, v.Options)
		}
	end

	self.ProfileCache[self.Profile] = savedata
	writefile(guiPath, httpService:JSONEncode(guidata))
	writefile('newvape/profiles/'..self.Profile..self.Place..'.txt', httpService:JSONEncode(savedata))
end

function mainapi:SaveOptions(object, savedoptions)
	if not savedoptions then return end
	savedoptions = {}
	for _, v in object.Options do
		if not v.Save then continue end
		v:Save(savedoptions)
	end
	return savedoptions
end

function mainapi:Uninject()
	mainapi:Save()
	mainapi.Loaded = nil
	for _, v in self.Modules do
		if v.Enabled then
			v:Toggle()
		end
		v.Button = nil
		v.Options = {}
	end
	for _, v in self.Legit.Modules do
		if v.Enabled then
			v:Toggle()
		end
	end
	for _, v in self.Categories do
		if v.Type == 'Overlay' and v.Button.Enabled then
			v.Button:Toggle()
		end
	end
	for _, v in mainapi.Connections do
		pcall(function()
			v:Disconnect()
		end)
	end
	if mainapi.ThreadFix then
		setthreadidentity(8)
		clickgui.Visible = false
		mainapi:BlurCheck()
	end
	mainapi.gui:ClearAllChildren()
	mainapi.gui:Destroy()
	table.clear(mainapi.Connections)
	table.clear(mainapi.Libraries)
	loopClean(mainapi)
	shared.vape = nil
	shared.vapereload = nil
	shared.VapeIndependent = nil
end

-- Jello uses compact category cards and a separate right-click settings sheet.
-- These implementations replace the inherited legacy window builders while
-- retaining the same public module/component API used by universal modules.
local function createJelloCategory(api, categorysettings, legit)
	local categoryapi = {
		Type = 'Category',
		Expanded = true,
		Options = {},
		Modules = legit and {} or nil
	}
	local moduleStore = legit and categoryapi.Modules or api.Modules
	local isMain = categorysettings.Name == 'GUI'
	local index = 0
	for name, category in api.Categories do
		if name ~= 'Main' and name ~= 'TopBar' and category.Type == 'Category' then index += 1 end
	end

	local window = Instance.new('TextButton')
	window.Name = categorysettings.Name..'Category'
	window.Size = UDim2.fromOffset(isMain and 116 or 142, 27)
	window.Position = isMain and UDim2.fromOffset(8, 72)
		or UDim2.fromOffset(140 + ((index % 4) * 148), 106 + (math.floor(index / 4) * 236))
	window.BackgroundColor3 = isMain and Color3.fromRGB(20, 20, 22) or uipallet.Panel
	window.BackgroundTransparency = isMain and 0.48 or 0.05
	window.BorderSizePixel = 0
	window.AutoButtonColor = false
	window.Visible = true
	window.Text = ''
	window.ClipsDescendants = false
	window.Parent = clickgui
	makeDraggable(window)
	if not isMain then addCorner(window, UDim.new(0, 2)) end

	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.new(1, -16, 1, 0)
	title.Position = UDim2.fromOffset(8, 0)
	title.BackgroundTransparency = 1
	title.Text = isMain and 'Categories' or categorysettings.Name
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = isMain and Color3.fromRGB(224, 224, 224) or uipallet.Text
	title.TextSize = isMain and 12 or 14
	title.FontFace = uipallet.Font
	title.Parent = window

	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 0, 0)
	children.Position = UDim2.fromOffset(0, 27)
	children.BackgroundColor3 = isMain and Color3.fromRGB(18, 18, 20) or uipallet.Panel
	children.BackgroundTransparency = isMain and 0.5 or 0.05
	children.BorderSizePixel = 0
	children.Visible = true
	children.ScrollBarThickness = 0
	children.CanvasSize = UDim2.new()
	children.Parent = window
	if not isMain then addCorner(children, UDim.new(0, 2)) end
	local windowlist = Instance.new('UIListLayout')
	windowlist.SortOrder = Enum.SortOrder.LayoutOrder
	windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	windowlist.Parent = children

	local function createModule(modulesettings)
		api:Remove(modulesettings.Name)
		local moduleapi = {
			Enabled = false,
			Options = {},
			Bind = {},
			Index = modulesettings.Index or getTableSize(moduleStore),
			ExtraText = modulesettings.ExtraText,
			Name = modulesettings.Name,
			Category = categorysettings.Name
		}
		modulesettings.Function = modulesettings.Function or function() end
		addMaid(moduleapi)

		local modulebutton = Instance.new('TextButton')
		modulebutton.Name = modulesettings.Name
		modulebutton.Size = UDim2.new(1, 0, 0, isMain and 25 or 22)
		modulebutton.BackgroundColor3 = isMain and Color3.fromRGB(28, 28, 31) or uipallet.Panel
		modulebutton.BackgroundTransparency = isMain and 0.48 or 0
		modulebutton.BorderSizePixel = 0
		modulebutton.AutoButtonColor = false
		modulebutton.Text = '  '..modulesettings.Name
		modulebutton.TextXAlignment = Enum.TextXAlignment.Left
		modulebutton.TextColor3 = isMain and Color3.fromRGB(219, 219, 219) or Color3.fromRGB(75, 75, 75)
		modulebutton.TextSize = isMain and 12 or 12
		modulebutton.FontFace = uipallet.Font
		modulebutton.Parent = children
		local gradient = Instance.new('UIGradient')
		gradient.Enabled = false
		gradient.Parent = modulebutton
		local accent = Instance.new('Frame')
		accent.Name = 'Accent'
		accent.Size = UDim2.new(1, 0, 0, isMain and 2 or 4)
		accent.Position = UDim2.new(0, 0, 1, isMain and -2 or -4)
		accent.BackgroundColor3 = uipallet.Accent
		accent.BorderSizePixel = 0
		accent.Visible = false
		accent.Parent = modulebutton
		local dots = Instance.new('Frame')
		dots.Name = 'Dots'
		dots.Size = UDim2.fromOffset(1, 1)
		dots.BackgroundTransparency = 1
		dots.Visible = false
		dots.Parent = modulebutton

		local settingswindow = Instance.new('Frame')
		settingswindow.Name = modulesettings.Name..'Settings'
		settingswindow.Size = UDim2.fromOffset(520, 620)
		settingswindow.Position = UDim2.fromScale(0.5, 0.5)
		settingswindow.AnchorPoint = Vector2.new(0.5, 0.5)
		settingswindow.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
		settingswindow.BorderSizePixel = 0
		settingswindow.Visible = false
		settingswindow.ZIndex = 50
		settingswindow.Parent = clickgui
		addCorner(settingswindow, UDim.new(0, 10))
		local stroke = Instance.new('UIStroke')
		stroke.Color = Color3.fromRGB(218, 218, 218)
		stroke.Thickness = 1
		stroke.Transparency = 0.35
		stroke.Parent = settingswindow
		local settingsTitle = Instance.new('TextLabel')
		settingsTitle.Size = UDim2.new(1, -70, 0, 52)
		settingsTitle.Position = UDim2.fromOffset(28, 13)
		settingsTitle.BackgroundTransparency = 1
		settingsTitle.Text = modulesettings.Name
		settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
		settingsTitle.TextColor3 = Color3.fromRGB(33, 33, 33)
		settingsTitle.TextSize = 34
		settingsTitle.FontFace = uipallet.Font
		settingsTitle.ZIndex = 51
		settingsTitle.Parent = settingswindow
		local description = settingsTitle:Clone()
		description.Size = UDim2.new(1, -58, 0, 28)
		description.Position = UDim2.fromOffset(30, 63)
		description.Text = modulesettings.Tooltip or 'Configure '..modulesettings.Name
		description.TextColor3 = uipallet.Muted
		description.TextSize = 16
		description.TextWrapped = true
		description.Parent = settingswindow
		local close = Instance.new('TextButton')
		close.Size = UDim2.fromOffset(42, 42)
		close.Position = UDim2.new(1, -53, 0, 14)
		close.BackgroundTransparency = 1
		close.Text = '×'
		close.TextColor3 = uipallet.Muted
		close.TextSize = 30
		close.FontFace = uipallet.Font
		close.ZIndex = 53
		close.Parent = settingswindow
		local settingschildren = Instance.new('ScrollingFrame')
		settingschildren.Name = 'Children'
		settingschildren.Size = UDim2.new(1, -44, 1, -116)
		settingschildren.Position = UDim2.fromOffset(22, 102)
		settingschildren.BackgroundTransparency = 1
		settingschildren.BorderSizePixel = 0
		settingschildren.ScrollBarThickness = 2
		settingschildren.ScrollBarImageColor3 = uipallet.Accent
		settingschildren.CanvasSize = UDim2.new()
		settingschildren.ZIndex = 51
		settingschildren.Parent = settingswindow
		local settingslist = Instance.new('UIListLayout')
		settingslist.SortOrder = Enum.SortOrder.LayoutOrder
		settingslist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		settingslist.Padding = UDim.new(0, 2)
		settingslist.Parent = settingschildren
		moduleapi.Children = settingschildren
		moduleapi.Settings = settingswindow

		function moduleapi:SetBind(value, mouse)
			value = type(value) == 'table' and value or {}
			local mobile = type(value.Mobile) == 'table' and value.Mobile or value.Mobile == true and value
			if mobile and type(mobile.X) == 'number' and type(mobile.Y) == 'number' then
				createMobileButton(moduleapi, Vector2.new(mobile.X, mobile.Y))
				return
			end
			self.Bind = bindKeys(value)
		end

		function moduleapi:Toggle(multiple)
			if api.ThreadFix then setthreadidentity(8) end
			self.Enabled = not self.Enabled
			accent.Visible = self.Enabled
			modulebutton.TextColor3 = isMain and Color3.fromRGB(232, 232, 232) or Color3.fromRGB(52, 52, 52)
			if not self.Enabled then
				for _, connection in self.Connections do pcall(function() connection:Disconnect() end) end
				table.clear(self.Connections)
			end
			if not multiple then api:UpdateTextGUI() end
			task.spawn(modulesettings.Function, self.Enabled)
		end

		for componentName, component in components do
			moduleapi['Create'..componentName] = function(_, optionsettings)
				return component(optionsettings, settingschildren, moduleapi)
			end
		end

		local function toggleSettings()
			if modulesettings.Special then return end
			if api.ActiveSettings and api.ActiveSettings ~= settingswindow then api.ActiveSettings.Visible = false end
			settingswindow.Visible = not settingswindow.Visible
			api.ActiveSettings = settingswindow.Visible and settingswindow or nil
		end
		close.MouseButton1Click:Connect(function()
			settingswindow.Visible = false
			if api.ActiveSettings == settingswindow then api.ActiveSettings = nil end
		end)
		modulebutton.MouseButton1Click:Connect(function() moduleapi:Toggle() end)
		modulebutton.MouseButton2Click:Connect(toggleSettings)
		modulebutton.MouseEnter:Connect(function()
			if not moduleapi.Enabled then modulebutton.BackgroundColor3 = isMain and Color3.fromRGB(36, 36, 40) or Color3.fromRGB(239, 239, 239) end
		end)
		modulebutton.MouseLeave:Connect(function()
			modulebutton.BackgroundColor3 = isMain and Color3.fromRGB(28, 28, 31) or uipallet.Panel
		end)
		settingslist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			settingschildren.CanvasSize = UDim2.fromOffset(0, settingslist.AbsoluteContentSize.Y / scale.Scale + 10)
		end)

		moduleapi.Object = modulebutton
		moduleStore[modulesettings.Name] = moduleapi
		local names = {}
		for name, object in moduleStore do
			if object.Category == categorysettings.Name then table.insert(names, name) end
		end
		table.sort(names)
		for order, name in names do
			moduleStore[name].Index = order
			moduleStore[name].Object.LayoutOrder = order
		end
		return moduleapi
	end

	categoryapi.CreateModule = function(_, settings) return createModule(settings) end
	for componentName, component in components do
		categoryapi['Create'..componentName] = function(_, settings)
			return component(settings, children, categoryapi)
		end
	end
	function categoryapi:Expand(force)
		self.Expanded = force == nil and not self.Expanded or force
		children.Visible = self.Expanded
	end
	window.MouseButton2Click:Connect(function() categoryapi:Expand() end)
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		local height = math.min(windowlist.AbsoluteContentSize.Y / scale.Scale, isMain and 410 or 205)
		children.CanvasSize = UDim2.fromOffset(0, windowlist.AbsoluteContentSize.Y / scale.Scale)
		children.Size = UDim2.new(1, 0, 0, height)
	end)
	categoryapi.Object = window
	return categoryapi
end

mainapi.CreateCategory = function(self, categorysettings)
	local categoryapi = createJelloCategory(self, categorysettings, false)
	if categorysettings.Name == 'GUI' then
		self.Categories.Main = categoryapi
	else
		categoryapi.Button = self.Categories.Main:CreateModule({
			Name = categorysettings.Name,
			Special = true,
			Function = function(enabled) categoryapi.Object.Visible = enabled end
		})
		categoryapi.Button.Enabled = true
		categoryapi.Button.Object.Accent.Visible = true
		self.Categories[categorysettings.Name] = categoryapi
	end
	return categoryapi
end

mainapi.CreateLegit = function(self, categorysettings)
	local categoryapi = createJelloCategory(self, categorysettings, true)
	categoryapi.Button = self.Categories.Main:CreateModule({
		Name = categorysettings.Name,
		Special = true,
		Function = function(enabled) categoryapi.Object.Visible = enabled end
	})
	categoryapi.Button.Enabled = true
	categoryapi.Button.Object.Accent.Visible = true
	self.Categories[categorysettings.Name] = categoryapi
	return categoryapi
end

gui = Instance.new('ScreenGui')
gui.Name = randomString()
gui.DisplayOrder = 9999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
gui.IgnoreGuiInset = true
gui.OnTopOfCoreBlur = true
if mainapi.ThreadFix then
	gui.Parent = (gethui and gethui()) or cloneref(game:GetService('CoreGui'))
else
	gui.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui
	gui.ResetOnSpawn = false
end
mainapi.gui = gui
scaledgui = Instance.new('Frame')
scaledgui.Name = 'ScaledGui'
scaledgui.Size = UDim2.fromScale(1, 1)
scaledgui.BackgroundTransparency = 1
scaledgui.Parent = gui
clickgui = Instance.new('Frame')
clickgui.Name = 'ClickGui'
clickgui.Size = UDim2.fromScale(1, 1)
clickgui.BackgroundTransparency = 1
clickgui.Visible = false
clickgui.Parent = scaledgui
local jelloBackdrop = Instance.new('Frame')
jelloBackdrop.Name = 'Backdrop'
jelloBackdrop.Size = UDim2.fromScale(1, 1)
jelloBackdrop.BackgroundColor3 = Color3.fromRGB(8, 13, 18)
jelloBackdrop.BackgroundTransparency = 0.48
jelloBackdrop.BorderSizePixel = 0
jelloBackdrop.ZIndex = 0
jelloBackdrop.Parent = clickgui
local backdropGradient = Instance.new('UIGradient')
backdropGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(46, 66, 83)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(17, 23, 31)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(46, 28, 49))
})
backdropGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.36),
	NumberSequenceKeypoint.new(0.5, 0.62),
	NumberSequenceKeypoint.new(1, 0.4)
})
backdropGradient.Parent = jelloBackdrop
local compass = Instance.new('TextLabel')
compass.Name = 'Compass'
compass.Size = UDim2.fromOffset(380, 28)
compass.Position = UDim2.new(0.5, -190, 0, 19)
compass.BackgroundTransparency = 1
compass.Text = 'N        NE        E        SE        S'
compass.TextColor3 = Color3.fromRGB(215, 215, 215)
compass.TextTransparency = 0.28
compass.TextSize = 12
compass.FontFace = uipallet.Font
compass.Parent = clickgui
local modal = Instance.new('TextButton')
modal.BackgroundTransparency = 1
modal.Modal = true
modal.Text = ''
modal.Parent = clickgui
local cursor = Instance.new('ImageLabel')
cursor.Size = UDim2.fromOffset(64, 64)
cursor.BackgroundTransparency = 1
cursor.Visible = false
cursor.Image = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'
cursor.Parent = gui
notifications = Instance.new('Folder')
notifications.Name = 'Notifications'
notifications.Parent = scaledgui
tooltip = Instance.new('TextLabel')
tooltip.Name = 'Tooltip'
tooltip.Position = UDim2.fromScale(-1, -1)
tooltip.ZIndex = 5
tooltip.BackgroundColor3 = color.Dark(uipallet.Main, 0.1)
tooltip.BackgroundTransparency = 0.5
tooltip.BorderSizePixel = 0
tooltip.Visible = false
tooltip.Text = ''
tooltip.TextColor3 = uipallet.Text
tooltip.TextSize = 14
tooltip.FontFace = uipallet.Font
tooltip.Parent = scaledgui
scale = Instance.new('UIScale')
scale.Scale = 1
scale.Parent = scaledgui
mainapi.guiscale = scale
scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)

mainapi:Clean(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
	if mainapi.Scale.Enabled then
		scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
	end
end))

mainapi:Clean(scale:GetPropertyChangedSignal('Scale'):Connect(function()
	scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
	for _, v in scaledgui:GetDescendants() do
		if v:IsA('GuiObject') and v.Visible then
			v.Visible = false
			v.Visible = true
		end
	end
end))

mainapi:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
	mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value, true)
	if clickgui.Visible and inputService.MouseEnabled then
		repeat
			local visibleCheck = clickgui.Visible
			for _, v in mainapi.Windows do
				visibleCheck = visibleCheck or v.Visible
			end
			if not visibleCheck then break end

			cursor.Visible = not inputService.MouseIconEnabled
			if cursor.Visible then
				local mouseLocation = inputService:GetMouseLocation()
				cursor.Position = UDim2.fromOffset(mouseLocation.X - 31, mouseLocation.Y - 32)
			end

			task.wait()
		until mainapi.Loaded == nil
		cursor.Visible = false
	end
end))

mainapi:CreateCategory({
	Name = 'GUI',
	Icon = getcustomasset('newvape/assets/jello/guiicon.png')
})
local combat = mainapi:CreateCategory({
	Name = 'Combat',
	Icon = getcustomasset('newvape/assets/jello/combaticon.png')
})
mainapi:CreateCategory({
	Name = 'Blatant',
	Icon = getcustomasset('newvape/assets/jello/blatanticon.png'),
	WindowSize = 164
})
mainapi:CreateCategory({
	Name = 'Render',
	Icon = getcustomasset('newvape/assets/jello/rendericon.png'),
	WindowSize = 196
})
mainapi:CreateCategory({
	Name = 'Utility',
	Icon = getcustomasset('newvape/assets/jello/utilityicon.png'),
	WindowSize = 164
})
mainapi:CreateCategory({
	Name = 'World',
	Icon = getcustomasset('newvape/assets/jello/worldicon.png')
})
mainapi:CreateCategory({
	Name = 'Inventory',
	Icon = getcustomasset('newvape/assets/jello/worldicon.png')
})
mainapi:CreateCategory({
	Name = 'Minigames',
	Icon = getcustomasset('newvape/assets/jello/worldicon.png')
})
mainapi.Legit = mainapi:CreateLegit({
	Name = 'Legit'
})
local settingspane = mainapi:CreateCategory({
	Name = 'Settings',
	Icon = getcustomasset('newvape/assets/jello/settingsicon.png'),
	WindowSize = 166
})


--[[
	Friends
]]
local friends
local friendscolor = {
	Hue = 1,
	Sat = 1,
	Value = 1
}
local friendssettings = {
	Name = 'Friends',
	Icon = getcustomasset('newvape/assets/jello/friendsicon.png'),
	Placeholder = 'Roblox username',
	WindowSize = 250,
	Function = function()
		friends.Update:Fire()
		friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
	end
}
friends = mainapi:CreateCategoryList(friendssettings)
friends.Update = Instance.new('BindableEvent')
friends.ColorUpdate = Instance.new('BindableEvent')
friendscolor = friends:CreateColorSlider({
	Name = 'Friends color',
	Darker = true,
	Function = function(hue, sat, val)
		friendssettings.Color = Color3.fromHSV(hue, sat, val)
		friends.ColorUpdate:Fire(hue, sat, val)
	end
})
friends:CreateToggle({
	Name = 'Recolor visuals',
	Darker = true,
	Default = true,
	Function = function()
		friends.Update:Fire()
		friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
	end
})
friends:CreateToggle({
	Name = 'Use friends',
	Darker = true,
	Default = true,
	Function = function()
		friends.Update:Fire()
		friends.ColorUpdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
	end
})
mainapi:Clean(friends.Update)
mainapi:Clean(friends.ColorUpdate)

--[[
	Profiles
]]
mainapi:CreateCategoryList({
	Name = 'Profiles',
	Icon = getcustomasset('newvape/assets/jello/profilesicon.png'),
	Placeholder = 'Type name',
	WindowSize = 250,
	Profiles = true
})

--[[
	Targets
]]
local targets
targets = mainapi:CreateCategoryList({
	Name = 'Targets',
	Icon = getcustomasset('newvape/assets/jello/friendsicon.png'),
	Placeholder = 'Roblox username',
	WindowSize = 250,
	Function = function()
		targets.Update:Fire()
	end
})
targets.Update = Instance.new('BindableEvent')
mainapi:Clean(targets.Update)

local topbar = mainapi:CreateBar()
mainapi.Categories.Main.Options = settingspane.Options

mainapi.GUIColor = settingspane:CreateColorSlider({
	Name = 'Gui Color',
	Function = function(h, s, v)
		mainapi:UpdateGUI(h, s, v, true)
	end
})

local function changedOptions()
	for _, module in mainapi.Modules do
		for _, option in module.Options do
			if option.Type == 'Targets' then
				option.Function()
			end
		end
	end
end

mainapi.TargetOptions = {
	Players = settingspane:CreateToggle({
		Name = 'Players',
		Function = changedOptions,
		Default = true
	}),
	NPCs = settingspane:CreateToggle({
		Name = 'NPCs',
		Function = changedOptions
	}),
	Invisible = settingspane:CreateToggle({
		Name = 'Ignore invisible',
		Function = changedOptions
	}),
	Walls = settingspane:CreateToggle({
		Name = 'Ignore behind walls',
		Function = changedOptions
	})
}
settingspane:CreateToggle({
	Name = 'Teams by server',
	Tooltip = 'Ignore players on your team designated by the server',
	Default = true,
	Function = function()
		if mainapi.Libraries.entity and mainapi.Libraries.entity.Running then
			mainapi.Libraries.entity.refresh()
		end
	end
})
settingspane:CreateToggle({
	Name = 'Use team color',
	Tooltip = 'Uses the TeamColor property on players for render modules',
	Default = true,
	Function = function()
		if mainapi.Libraries.entity and mainapi.Libraries.entity.Running then
			mainapi.Libraries.entity.refresh()
		end
	end
})


--[[
	GUI Settings
]]

mainapi.Blur = topbar:CreateToggle({
	Name = 'Blur background',
	Function = function()
		mainapi:BlurCheck()
	end,
	Default = true,
	Tooltip = 'Blur the background of the GUI'
})
mainapi.Categories.Main.Options['GUI bind indicator'] = topbar:CreateToggle({
	Name = 'GUI bind indicator',
	Default = true,
	Tooltip = "Displays a message indicating your GUI upon injecting.\nI.E. 'Press RSHIFT to open GUI'"
})
topbar:CreateToggle({
	Name = 'Show tooltips',
	Function = function(enabled)
		tooltip.Visible = false
	end,
	Default = true,
	Tooltip = 'Toggles visibility of these'
})
mainapi.MultiKeybind = topbar:CreateToggle({
	Name = 'Enable Multi-Keybinding',
	Tooltip = 'Allows multiple keys to be bound to a module (eg. G + H)'
})
mainapi.Notifications = topbar:CreateToggle({
	Name = 'Notifications',
	Function = function(enabled)
		if mainapi.ToggleNotifications.Object then
			mainapi.ToggleNotifications.Object.Visible = enabled
		end
	end,
	Tooltip = 'Shows notifications',
	Default = true
})
mainapi.ToggleNotifications = topbar:CreateToggle({
	Name = 'Toggle alert',
	Tooltip = 'Notifies you if a module is enabled/disabled.',
	Default = true,
	Darker = true
})
local scaleslider = {Object = {}, Value = 1}
mainapi.Scale = topbar:CreateToggle({
	Name = 'Auto rescale',
	Default = true,
	Function = function(callback)
		scaleslider.Object.Visible = not callback
		if callback then
			scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.6)
		else
			scale.Scale = scaleslider.Value
		end
	end,
	Tooltip = 'Automatically rescales the gui using the screens resolution'
})
scaleslider = topbar:CreateSlider({
	Name = 'Scale',
	Min = 0.1,
	Max = 2,
	Decimal = 10,
	Function = function(val, final)
		if final and not mainapi.Scale.Enabled then
			scale.Scale = val
		end
	end,
	Default = 1,
	Darker = true,
	Visible = false
})
topbar:CreateDropdown({
	Name = 'GUI Theme',
	List = inputService.TouchEnabled and {'jello', 'new', 'old'} or {'jello', 'new', 'old', 'rise', 'liquidbounce'},
	Function = function(val, mouse)
		if mouse then
			writefile('newvape/profiles/gui.txt', val)
			shared.vapereload = true
			if shared.VapeDeveloper then
				loadstring(readfile('newvape/loader.lua'), 'loader')()
			else
				loadstring(game:HttpGet('https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/main/src/loader.lua', true))()
			end
		end
	end,
	Tooltip = 'jello - Sigma Jello inspired interface\nnew/old - Vape themes\nrise/liquidbounce - alternate interfaces'
})
mainapi.RainbowMode = topbar:CreateDropdown({
	Name = 'Rainbow Mode',
	List = {'Normal', 'Gradient', 'Retro'},
	Tooltip = 'Normal - Smooth color fade\nGradient - Gradient color fade\nRetro - Static color'
})
mainapi.RainbowSpeed = topbar:CreateSlider({
	Name = 'Rainbow speed',
	Min = 0.1,
	Max = 10,
	Decimal = 10,
	Default = 1,
	Tooltip = 'Adjusts the speed of rainbow values'
})
mainapi.RainbowUpdateSpeed = topbar:CreateSlider({
	Name = 'Rainbow update rate',
	Min = 1,
	Max = 144,
	Default = 60,
	Tooltip = 'Adjusts the update rate of rainbow values',
	Suffix = 'hz'
})
topbar:CreateButton({
	Name = 'Reset current profile',
	Function = function()
	mainapi.Save = function() end
		if isfile('newvape/profiles/'..mainapi.Profile..mainapi.Place..'.txt') and delfile then
			delfile('newvape/profiles/'..mainapi.Profile..mainapi.Place..'.txt')
		end
		shared.vapereload = true
		if shared.VapeDeveloper then
			loadstring(readfile('newvape/loader.lua'), 'loader')()
		else
			loadstring(game:HttpGet('https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/main/src/loader.lua', true))()
		end
	end,
	Tooltip = 'This will set your profile to the default settings of Vape'
})
topbar:CreateButton({
	Name = 'Reset GUI positions',
	Function = function()
		for _, v in mainapi.Categories do
			v.Object.Position = UDim2.fromOffset(4, 68)
		end
	end,
	Tooltip = 'This will reset your GUI back to default'
})
topbar:CreateButton({
	Name = 'Sort GUI',
	Function = function()
		local priority = {
			GUICategory = 1,
			CombatCategory = 2,
			BlatantCategory = 3,
			RenderCategory = 4,
			UtilityCategory = 5,
			WorldCategory = 6,
			InventoryCategory = 7,
			MinigamesCategory = 8,
			LegitCategory = 9,
			FriendsCategory = 10,
			ProfilesCategory = 11
		}
		local categories = {}
		for _, v in mainapi.Categories do
			if v.Type ~= 'Overlay' and not v.TopBar then
				table.insert(categories, v)
			end
		end
		table.sort(categories, function(a, b) return
			(priority[a.Object.Name] or 99) < (priority[b.Object.Name] or 99)
		end)

		local offset = 4
		for _, v in categories do
			if v.Object.Visible then
				v.Object.Position = UDim2.fromOffset(offset, 68)
				offset += v.Object.Size.X.Offset + 6
			end
		end
	end,
	Tooltip = 'Sorts GUI'
})
topbar:CreateButton({
	Name = 'UNINJECT',
	Function = function()
		mainapi:Uninject()
	end,
	Tooltip = 'Removes vape from the current game'
})
topbar:CreateButton({
	Name = 'REINEJCT',
	Function = function()
		shared.vapereload = true
		if shared.VapeDeveloper then
			loadstring(readfile('newvape/loader.lua'), 'loader')()
		else
			loadstring(game:HttpGet('https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/main/src/loader.lua', true))()
		end
	end,
	Tooltip = 'Reloads vape for debugging purposes'
})
topbar:CreateBind()

--[[
	Target Info
]]

local targetinfo
local targetinfoobj
local targetinfobcolor
targetinfoobj = mainapi:CreateOverlay({
	Name = 'Target Info',
	Icon = 'rbxasset://targetinfoicon.png',
	Function = function(callback)
		if callback then
			task.spawn(function()
				repeat
					targetinfo:UpdateInfo()
					task.wait()
				until not targetinfoobj.Button or not targetinfoobj.Button.Enabled
			end)
		end
	end,
	WindowSize = 246
})

local targetinfobkg = Instance.new('Frame')
targetinfobkg.Size = UDim2.fromOffset(246, 74)
targetinfobkg.BackgroundColor3 = uipallet.Main
targetinfobkg.BackgroundTransparency = 0.06
targetinfobkg.BorderSizePixel = 0
targetinfobkg.Parent = targetinfoobj.Children
local targetinfoshot = Instance.new('ImageLabel')
targetinfoshot.Size = UDim2.fromOffset(62, 62)
targetinfoshot.Position = UDim2.fromOffset(6, 6)
targetinfoshot.BackgroundColor3 = color.Light(uipallet.Main, 0.05)
targetinfoshot.BorderColor3 = color.Light(uipallet.Main, 0.2)
targetinfoshot.Image = 'rbxthumb://type=AvatarHeadShot&id=1&w=420&h=420'
targetinfoshot.Parent = targetinfobkg
local targetinfoshotflash = Instance.new('Frame')
targetinfoshotflash.Size = UDim2.fromScale(1, 1)
targetinfoshotflash.BackgroundTransparency = 1
targetinfoshotflash.BackgroundColor3 = Color3.new(1, 0, 0)
targetinfoshotflash.BorderSizePixel = 0
targetinfoshotflash.Parent = targetinfoshot
local targetinfoname = Instance.new('TextLabel')
targetinfoname.Size = UDim2.fromOffset(145, 18)
targetinfoname.Position = UDim2.fromOffset(73, 3)
targetinfoname.BackgroundTransparency = 1
targetinfoname.Text = 'Target Name'
targetinfoname.TextXAlignment = Enum.TextXAlignment.Left
targetinfoname.TextYAlignment = Enum.TextYAlignment.Top
targetinfoname.TextScaled = true
targetinfoname.TextColor3 = uipallet.Text
targetinfoname.TextStrokeTransparency = 1
targetinfoname.FontFace = uipallet.Font
local targetinfoshadow = targetinfoname:Clone()
targetinfoshadow.Position = UDim2.fromOffset(74, 4)
targetinfoshadow.TextColor3 = Color3.new()
targetinfoshadow.TextTransparency = 0.65
targetinfoshadow.Parent = targetinfobkg
targetinfoname.Parent = targetinfobkg
targetinfoname:GetPropertyChangedSignal('Text'):Connect(function()
	targetinfoshadow.Text = targetinfoname.Text
end)
local targetinfohealthbkg = Instance.new('Frame')
targetinfohealthbkg.Name = 'HealthBKG'
targetinfohealthbkg.Size = UDim2.fromOffset(98, 6)
targetinfohealthbkg.Position = UDim2.fromOffset(74, 25)
targetinfohealthbkg.BackgroundColor3 = uipallet.Main
targetinfohealthbkg.BorderColor3 = color.Light(uipallet.Main, 0.2)
targetinfohealthbkg.Parent = targetinfobkg
local targetinfohealth = targetinfohealthbkg:Clone()
targetinfohealth.Size = UDim2.fromScale(0.8, 1)
targetinfohealth.Position = UDim2.new()
targetinfohealth.BackgroundColor3 = Color3.new(1, 1, 0)
targetinfohealth.BorderSizePixel = 0
targetinfohealth.Parent = targetinfohealthbkg
local targetinfohealthextra = targetinfohealth:Clone()
targetinfohealthextra.Size = UDim2.new()
targetinfohealthextra.Position = UDim2.fromScale(1, 0)
targetinfohealthextra.AnchorPoint = Vector2.new(1, 0)
targetinfohealthextra.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
targetinfohealthextra.Visible = false
targetinfohealthextra.Parent = targetinfohealthbkg
local targetinfohealthtext = targetinfoname:Clone()
targetinfohealthtext.Size = UDim2.fromOffset(145, 12)
targetinfohealthtext.Position = UDim2.fromOffset(177, 22)
targetinfohealthtext.BackgroundTransparency = 1
targetinfohealthtext.Text = '80 hp'
local targetinfoshadow2 = targetinfohealthtext:Clone()
targetinfoshadow2.Position = UDim2.fromOffset(178, 23)
targetinfoshadow2.TextColor3 = Color3.new()
targetinfoshadow2.TextTransparency = 0.65
targetinfoshadow2.Parent = targetinfobkg
targetinfohealthtext.Parent = targetinfobkg

local targetinfobackgroundtransparency = {
	Value = 0.5,
	Object = {Visible = {}}
}
local targetinfodisplay = targetinfoobj:CreateToggle({
	Name = 'Use Displayname',
	Default = true
})

local lasthealth = 0
local lastmaxhealth = 0
targetinfo = {
	Targets = {},
	Object = targetinfobkg,
	UpdateInfo = function(self)
		local entitylib = mainapi.Libraries
		if not entitylib then return end
		for i, v in self.Targets do
			if v < tick() then
				self.Targets[i] = nil
			end
		end

		local v, highest = nil, tick()
		for i, check in self.Targets do
			if check > highest then
				v = i
				highest = check
			end
		end

		targetinfobkg.Visible = v ~= nil or mainapi.gui.ScaledGui.ClickGui.Visible
		if v then
			targetinfoname.Text = v.Player and (targetinfodisplay.Enabled and v.Player.DisplayName or v.Player.Name) or v.Character and v.Character.Name or targetinfoname.Text
			targetinfoshot.Image = 'rbxthumb://type=AvatarHeadShot&id='..(v.Player and v.Player.UserId or 1)..'&w=420&h=420'

			if not v.Character then
				v.Health = v.Health or 0
				v.MaxHealth = v.MaxHealth or 100
			end

			if v.Health ~= lasthealth or v.MaxHealth ~= lastmaxhealth then
				local percent = math.max(v.Health / v.MaxHealth, 0)
				targetinfohealth.Size = UDim2.fromScale(math.min(percent, 1), 1)
				targetinfohealth.BackgroundColor3 = Color3.fromHSV(math.clamp(percent / 2.5, 0, 1), 0.89, 0.75)
				targetinfohealthextra.Size = UDim2.fromScale(math.clamp(percent - 1, 0, 0.8), 1)
				targetinfohealthtext.Text = math.round(v.Health)..' hp'
				if lasthealth > v.Health and self.LastTarget == v then
					tween:Cancel(targetinfoshotflash)
					targetinfoshotflash.BackgroundTransparency = 0.3
					tween:Tween(targetinfoshotflash, TweenInfo.new(0.5), {
						BackgroundTransparency = 1
					})
				end
				lasthealth = v.Health
				lastmaxhealth = v.MaxHealth
			end

			if not v.Character then table.clear(v) end
			self.LastTarget = v
		end
		return v
	end
}
mainapi.Libraries.targetinfo = targetinfo

--[[
	Text GUI
]]

local textgui = mainapi:CreateOverlay({
	Name = 'Text GUI',
	Icon = getcustomasset('newvape/assets/jello/textguiicon.png'),
	WindowSize = 178,
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguisort = textgui:CreateDropdown({
	Name = 'Sort',
	List = {'Alphabetical', 'Length'},
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local VapeTextScale = Instance.new('UIScale')
VapeTextScale.Parent = textgui.Children
local textguiscale = textgui:CreateSlider({
	Name = 'Scale',
	Min = 0,
	Max = 2,
	Decimal = 10,
	Default = 1,
	Function = function(val)
		VapeTextScale.Scale = val
		mainapi:UpdateTextGUI()
	end
})
local textguishadow = textgui:CreateToggle({
	Name = 'Shadow',
	Tooltip = 'Renders shadowed text.',
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguiwatermark = textgui:CreateToggle({
	Name = 'Watermark',
	Tooltip = 'Renders a vape watermark',
	Function = function()
		mainapi:UpdateTextGUI()
	end
})
local textguibackground = textgui:CreateToggle({
	Name = 'Render background',
	Function = function(callback)
		mainapi:UpdateTextGUI()
	end
})
local textguimoduleslist
local textguimodules = textgui:CreateToggle({
	Name = 'Hide modules',
	Tooltip = 'Allows you to blacklist certain modules from being shown.',
	Function = function(enabled)
		if textguimoduleslist then textguimoduleslist.Object.Visible = enabled end
		mainapi:UpdateTextGUI()
	end
})
textguimoduleslist = textgui:CreateTextList({
	Name = 'Blacklist',
	Tooltip = 'Name of module to hide.',
	Icon = getcustomasset('new/blockedicon.png'),
	Tab = getcustomasset('new/blockedtab.png'),
	TabSize = UDim2.fromOffset(21, 16),
	Color = Color3.fromRGB(250, 50, 56),
	Function = function()
		mainapi:UpdateTextGUI()
	end,
	Visible = false,
	Darker = true
})
local textguirender = textgui:CreateToggle({
	Name = 'Hide render',
	Function = function(enabled)
		mainapi:UpdateTextGUI()
	end
})

--[[
	Text GUI Objects
]]

local VapeLabels = {}
local VapeLogo = Instance.new('ImageLabel')
VapeLogo.Name = 'Logo'
VapeLogo.Size = UDim2.fromOffset(96, 26)
VapeLogo.Position = UDim2.new(1, -142, 0, 3)
VapeLogo.BackgroundTransparency = 1
VapeLogo.BorderSizePixel = 0
VapeLogo.Visible = true
VapeLogo.BackgroundColor3 = Color3.new()
VapeLogo.Image = getcustomasset('newvape/assets/jello/textvape.png')
VapeLogo.ImageTransparency = 1
VapeLogo.Parent = textgui.Children
local JelloLogoText = Instance.new('TextLabel')
JelloLogoText.Name = 'JelloLogoText'
JelloLogoText.Size = UDim2.fromOffset(132, 42)
JelloLogoText.Position = UDim2.fromOffset(-34, -4)
JelloLogoText.BackgroundTransparency = 1
JelloLogoText.Text = 'Sigma\nJello'
JelloLogoText.TextXAlignment = Enum.TextXAlignment.Right
JelloLogoText.TextYAlignment = Enum.TextYAlignment.Top
JelloLogoText.TextColor3 = Color3.new(1, 1, 1)
JelloLogoText.TextSize = 21
JelloLogoText.FontFace = uipallet.Font
JelloLogoText.Parent = VapeLogo

local lastside = textgui.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
mainapi:Clean(textgui.Children:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
	if mainapi.ThreadFix then
		setthreadidentity(8)
	end
	local newside = textgui.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
	if lastside ~= newside then
		lastside = newside
		mainapi:UpdateTextGUI()
	end
end))

local VapeLogoV4 = Instance.new('ImageLabel')
VapeLogoV4.Name = 'Logo2'
VapeLogoV4.Size = UDim2.fromOffset(43, 30)
VapeLogoV4.Position = UDim2.new(1, 1, 0, -2)
VapeLogoV4.BackgroundColor3 = Color3.new()
VapeLogoV4.BackgroundTransparency = 1
VapeLogoV4.BorderSizePixel = 0
VapeLogoV4.Image = getcustomasset('newvape/assets/jello/textv4.png')
VapeLogoV4.Visible = false
VapeLogoV4.Parent = VapeLogo
local VapeLogoShadow = VapeLogo:Clone()
VapeLogoShadow.Position = UDim2.fromOffset(1, 1)
VapeLogoShadow.ZIndex = 0
VapeLogoShadow.Visible = true
VapeLogoShadow.ImageColor3 = Color3.new()
VapeLogoShadow.ImageTransparency = 0.65
VapeLogoShadow.Parent = VapeLogo
VapeLogoShadow.Logo2.ZIndex = 0
VapeLogoShadow.Logo2.ImageColor3 = Color3.new()
VapeLogoShadow.Logo2.ImageTransparency = 0.65
VapeLogoShadow.JelloLogoText.Visible = false
local VapeLogoGradient = Instance.new('UIGradient')
VapeLogoGradient.Rotation = 90
VapeLogoGradient.Parent = VapeLogo
local VapeLogoGradient2 = Instance.new('UIGradient')
VapeLogoGradient2.Rotation = 90
VapeLogoGradient2.Parent = VapeLogoV4
local VapeLabelHolder = Instance.new('Frame')
VapeLabelHolder.Name = 'Holder'
VapeLabelHolder.Size = UDim2.fromScale(1, 1)
VapeLabelHolder.Position = UDim2.fromOffset(5, 37)
VapeLabelHolder.BackgroundTransparency = 1
VapeLabelHolder.Parent = textgui.Children
local VapeLabelSorter = Instance.new('UIListLayout')
VapeLabelSorter.HorizontalAlignment = Enum.HorizontalAlignment.Right
VapeLabelSorter.VerticalAlignment = Enum.VerticalAlignment.Top
VapeLabelSorter.SortOrder = Enum.SortOrder.LayoutOrder
VapeLabelSorter.Parent = VapeLabelHolder

function mainapi:UpdateTextGUI(afterload)
	if not afterload and not mainapi.Loaded then return end
	if textgui.Button.Enabled then
		local right = textgui.Children.AbsolutePosition.X > (gui.AbsoluteSize.X / 2)
		VapeLogo.Visible = textguiwatermark.Enabled
		VapeLogo.Position = right and UDim2.new(1 / VapeTextScale.Scale, -141, 0, 4) or UDim2.fromOffset(5, 4)
		VapeLogoShadow.Visible = textguishadow.Enabled
		VapeLabelSorter.HorizontalAlignment = right and Enum.HorizontalAlignment.Right or Enum.HorizontalAlignment.Left
		VapeLabelHolder.Size = UDim2.fromScale(1 / VapeTextScale.Scale, 1)
		VapeLabelHolder.Position = UDim2.fromOffset(4, 4 + (VapeLogo.Visible and VapeLogo.Size.Y.Offset or 0))

		local found = {}
		for _, v in VapeLabels do
			if v.Enabled then
				table.insert(found, v.Object.Name)
			end
			v.Object:Destroy()
		end
		table.clear(VapeLabels)

		for i, v in mainapi.Modules do
			if textguimodules.Enabled and textguimoduleslist and table.find(textguimoduleslist.ListEnabled, i) then continue end
			if textguirender.Enabled and v.Category == 'Render' then continue end
			if v.Category == 'GUI' then continue end
			if v.Enabled or table.find(found, i) then
				local holder = Instance.new('Frame')
				holder.Name = i
				holder.Size = UDim2.fromOffset()
				holder.BackgroundTransparency = 1
				holder.ClipsDescendants = true
				holder.Parent = VapeLabelHolder
				local holdertext = Instance.new('TextLabel')
				holdertext.Position = UDim2.fromOffset(right and 3 or 0, 2)
				holdertext.BackgroundTransparency = 1
				holdertext.BorderSizePixel = 0
				holdertext.Text = i..(v.ExtraText and " <font color='#A8A8A8'>"..v.ExtraText()..'</font>' or '')
				holdertext.TextSize = 18
				holdertext.FontFace = uipallet.Font
				holdertext.RichText = true
				local size = getfontsize(removeTags(holdertext.Text), holdertext.TextSize, holdertext.FontFace)
				holdertext.Size = UDim2.fromOffset(size.X, size.Y)
				if textguishadow.Enabled then
					local holderdrop = holdertext:Clone()
					holderdrop.Position = UDim2.fromOffset(holdertext.Position.X.Offset + 1, holdertext.Position.Y.Offset + 1)
					holderdrop.Text = removeTags(holdertext.Text)
					holderdrop.TextColor3 = Color3.new()
					holderdrop.TextTransparency = 0.65
					holderdrop.Parent = holder
				end
				holdertext.Parent = holder
				local holdersize = UDim2.fromOffset(size.X + 10, size.Y + 3)
				holder.Size = v.Enabled and holdersize or UDim2.fromOffset()
				table.insert(VapeLabels, {
					Object = holder,
					Text = holdertext,
					Enabled = v.Enabled
				})
			end
		end

		if textguisort.Value == 'Alphabetical' then
			table.sort(VapeLabels, function(a, b)
				return a.Text.Text < b.Text.Text
			end)
		else
			table.sort(VapeLabels, function(a, b)
				return a.Text.Size.X.Offset > b.Text.Size.X.Offset
			end)
		end

		for i, v in VapeLabels do
			if v.Color then
				v.Color.Parent.Line.Visible = i ~= 1
			end
			v.Object.LayoutOrder = i
		end
	end

	mainapi:UpdateGUI(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value, true)
end

function mainapi:UpdateModuleColor(button, hue, sat, val, default, rainbowcheck)
	local accent = button.Object and button.Object:FindFirstChild('Accent')
	if accent then
		accent.Visible = button.Enabled
		accent.BackgroundColor3 = rainbowcheck
			and Color3.fromHSV(mainapi:Color((hue - (button.Index * 0.025)) % 1))
			or Color3.fromHSV(hue, sat, val)
	end

	for _, option in button.Options do
		if option.Color then
			option:Color(hue, sat, val, rainbowcheck)
		end
	end
end

function mainapi:UpdateGUI(hue, sat, val, default)
	if mainapi.Loaded == nil then return end
	if not default and mainapi.GUIColor.Rainbow then return end
	if textgui.Button.Enabled then
		JelloLogoText.TextColor3 = Color3.fromHSV(hue, sat, val)
		VapeLogoGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, sat, val)),
			ColorSequenceKeypoint.new(1, mainapi.GUIColor.Rainbow and Color3.fromHSV(mainapi:Color((hue - 0.075) % 1)) or Color3.fromHSV(hue, sat, val))
		})
		VapeLogoGradient2.Color = mainapi.GUIColor.Rainbow and VapeLogoGradient.Color or ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		})
		for i, v in VapeLabels do
			v.Text.TextColor3 = customcolor or (mainapi.GUIColor.Rainbow and Color3.fromHSV(mainapi:Color((hue - ((i + 2) * 0.025)) % 1)) or VapeLogoGradient.Color.Keypoints[2].Value)
		end
	end

	if not clickgui.Visible then return end
	local rainbowcheck = mainapi.GUIColor.Rainbow and mainapi.RainbowMode.Value ~= 'Retro'

	for i, v in mainapi.Categories do
		if v.Options then
			for _, option in v.Options do
				if option.Color then option:Color(hue, sat, val, rainbowcheck) end
			end
		end

		if v.Type == 'CategoryList' then
			if not v.Profiles then
				for _, obj in v.Objects do
					obj.Dot.ImageLabel.ImageColor3 = Color3.fromHSV(mainapi:Color(hue))
				end
			end

			if v.Selected then
				v.Selected.BKG.BackgroundColor3 = rainbowcheck and Color3.fromHSV(mainapi:Color(hue % 1)) or Color3.fromHSV(hue, sat, val)
				v.Selected.Title.TextColor3 = mainapi.GUIColor.Rainbow and Color3.new(0.19, 0.19, 0.19) or mainapi:TextColor(hue, sat, val)
			end
		end
	end

	for _, button in mainapi.Modules do
		self:UpdateModuleColor(button, hue, sat, val, default, rainbowcheck)
	end

	if mainapi.Legit then
		for _, button in mainapi.Legit.Modules do
			self:UpdateModuleColor(button, hue, sat, val, default, rainbowcheck)
		end
	end
end

mainapi:Clean(notifications.ChildRemoved:Connect(function()
	for i, v in notifications:GetChildren() do
		if tween.Tween then
			tween:Tween(v, TweenInfo.new(0.4, Enum.EasingStyle.Exponential), {
				Position = UDim2.new(1, 0, 1, -(29 + (44 * i)))
			})
		end
	end
end))

mainapi:Clean(inputService.InputBegan:Connect(function(inputObj)
	if not inputService:GetFocusedTextBox() and inputObj.KeyCode ~= Enum.KeyCode.Unknown then
		table.insert(mainapi.HeldKeybinds, inputObj.KeyCode.Name)
		if mainapi.Binding then return end

		if checkKeybinds(mainapi.HeldKeybinds, mainapi.Keybind, inputObj.KeyCode.Name) then
			if mainapi.ThreadFix then
				setthreadidentity(8)
			end
			for _, v in mainapi.Windows do
				v.Visible = false
			end
			clickgui.Visible = not clickgui.Visible
			tooltip.Visible = false
			mainapi:BlurCheck()
		end

		local toggled = false
		for i, v in mainapi.Modules do
			if checkKeybinds(mainapi.HeldKeybinds, v.Bind, inputObj.KeyCode.Name) then
				toggled = true
				if mainapi.ToggleNotifications.Enabled then
					mainapi:CreateNotification('Module Toggled', i.."<font color='#FFFFFF'> has been </font>"..(not v.Enabled and "<font color='#5AFF5A'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>").."<font color='#FFFFFF'>!</font>", 0.75)
				end
				v:Toggle(true)
			end
		end
		if toggled then
			mainapi:UpdateTextGUI()
		end

		for _, v in mainapi.Profiles do
			if checkKeybinds(mainapi.HeldKeybinds, v.Bind, inputObj.KeyCode.Name) and v.Name ~= mainapi.Profile then
				mainapi:Save(v.Name)
				mainapi:Load(true)
				break
			end
		end
	end
end))

mainapi:Clean(inputService.InputEnded:Connect(function(inputObj)
	if not inputService:GetFocusedTextBox() and inputObj.KeyCode ~= Enum.KeyCode.Unknown then
		if mainapi.Binding and inputObj.KeyCode.Name ~= 'LeftShift' then
			if not mainapi.MultiKeybind.Enabled then
				mainapi.HeldKeybinds = {inputObj.KeyCode.Name}
			end
			mainapi.Binding:SetBind(checkKeybinds(mainapi.HeldKeybinds, mainapi.Binding.Bind, inputObj.KeyCode.Name) and {} or mainapi.HeldKeybinds, true)
			mainapi.Binding = nil
		end
	end

	local ind = table.find(mainapi.HeldKeybinds, inputObj.KeyCode.Name)
	if ind then
		table.remove(mainapi.HeldKeybinds, ind)
	end
end))

return mainapi
