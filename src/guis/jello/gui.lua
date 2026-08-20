local mainapi = {
	Categories = {},
	GUIColor = {
		Hue = 0.55,
		Sat = 0.85,
		Value = 0.9,
		Rainbow = false
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
	Version = 'Jello 1.1',
	Windows = {}
}

-- Some option defaults are applied while the interface is still being built.
-- The complete renderer replaces this no-op once the Text GUI objects exist.
mainapi.UpdateTextGUI = function() end

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
local clickguiScale
local modalBackdrop
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
	Accent = Color3.fromRGB(35, 171, 230),
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
	['newvape/assets/jello/jelloreg.ttf'] = '',
	['newvape/assets/jello/jellosemibold.ttf'] = ''
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
			faces = {
				{
					name = 'Regular',
					weight = 400,
					style = 'normal',
					assetId = getcustomasset(
						'newvape/assets/jello/jelloreg.ttf'
					)
				},
				{
					name = 'SemiBold',
					weight = 600,
					style = 'normal',
					assetId = getcustomasset(
						'newvape/assets/jello/jellosemibold.ttf'
					)
				}
			}
		}))

		local family = getcustomasset(familyPath)

		uipallet.Font = Font.new(
			family,
			Enum.FontWeight.Regular,
			Enum.FontStyle.Normal
		)

		uipallet.FontSemiBold = Font.new(
			family,
			Enum.FontWeight.SemiBold,
			Enum.FontStyle.Normal
		)
	end)

	if not success then
		uipallet.Font = Font.fromEnum(Enum.Font.Arial)
		uipallet.FontSemiBold = Font.fromEnum(
			Enum.Font.Arial,
			Enum.FontWeight.SemiBold
		)
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
		local blurEnabled = not self.Blur or self.Blur.Enabled
		runService:SetRobloxGuiFocused((self.ClickGUIOpen or guiService:GetErrorType() ~= Enum.ConnectionError.OK) and blurEnabled)
	end
end

addMaid(mainapi)

function mainapi:CreateBar()
	local categoryapi = {
		Type = 'Category',
		Expanded = true,
		Options = mainapi.ClientSettings and mainapi.ClientSettings.Options or {},
		TopBar = true
	}

	local bar = Instance.new('Frame')
	bar.Name = 'JelloBar'
	bar.Size = UDim2.fromOffset(124, 62)
	bar.Position = UDim2.fromOffset(9, 8)
	bar.BackgroundTransparency = 1
	bar.BorderSizePixel = 0
	bar.Parent = clickgui

	local logo = Instance.new('TextLabel')
	logo.Size = UDim2.fromOffset(118, 39)
	logo.BackgroundTransparency = 1
	logo.Text = 'Sigma'
	logo.TextXAlignment = Enum.TextXAlignment.Left
	logo.TextColor3 = Color3.fromRGB(238, 238, 238)
	logo.TextSize = 31
	logo.FontFace = uipallet.Font
	logo.Parent = bar
	local sublogo = logo:Clone()
	sublogo.Size = UDim2.fromOffset(86, 17)
	sublogo.Position = UDim2.fromOffset(2, 35)
	sublogo.Text = 'Jello'
	sublogo.TextSize = 13
	sublogo.TextColor3 = Color3.fromRGB(210, 210, 210)
	sublogo.Parent = bar

	local keyManager = Instance.new('CanvasGroup')
	keyManager.Name = 'KeybindManager'
	keyManager.Size = UDim2.fromOffset(1120, 470)
	keyManager.Position = UDim2.fromScale(0.5, 0.5)
	keyManager.AnchorPoint = Vector2.new(0.5, 0.5)
	keyManager.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
	keyManager.BorderSizePixel = 0
	keyManager.Visible = false
	keyManager.ZIndex = 41
	keyManager.Parent = modalBackdrop
	addCorner(keyManager, UDim.new(0, 11))
	local managerStroke = Instance.new('UIStroke')
	managerStroke.Color = Color3.fromRGB(220, 220, 220)
	managerStroke.Transparency = 0.35
	managerStroke.Parent = keyManager
	table.insert(mainapi.Windows, keyManager)

	local managerTitle = Instance.new('TextLabel')
	managerTitle.Size = UDim2.new(1, -80, 0, 66)
	managerTitle.Position = UDim2.fromOffset(22, 5)
	managerTitle.BackgroundTransparency = 1
	managerTitle.Text = 'Keybind Manager'
	managerTitle.TextXAlignment = Enum.TextXAlignment.Left
	managerTitle.TextColor3 = Color3.fromRGB(68, 68, 68)
	managerTitle.TextSize = 35
	managerTitle.FontFace = uipallet.Font
	managerTitle.ZIndex = 42
	managerTitle.Parent = keyManager
	local managerClose = Instance.new('TextButton')
	managerClose.Size = UDim2.fromOffset(42, 42)
	managerClose.Position = UDim2.new(1, -52, 0, 12)
	managerClose.BackgroundTransparency = 1
	managerClose.Text = '×'
	managerClose.TextColor3 = uipallet.Muted
	managerClose.TextSize = 30
	managerClose.FontFace = uipallet.Font
	managerClose.ZIndex = 46
	managerClose.Parent = keyManager

	local keyboard = Instance.new('Frame')
	keyboard.Size = UDim2.new(1, -40, 1, -82)
	keyboard.Position = UDim2.fromOffset(20, 70)
	keyboard.BackgroundTransparency = 1
	keyboard.ZIndex = 42
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
	local function eachBindableModule(callback)
		for name, module in mainapi.Modules do callback(name, module) end
		if mainapi.Legit then
			for name, module in mainapi.Legit.Modules do callback(name, module) end
		end
	end

	local function closeSelector()
		if selector then selector:Destroy(); selector = nil end
	end

	local function openSelector(key, reopen)
		closeSelector()
		selector = Instance.new('CanvasGroup')
		selector.Name = 'ModuleSelector'
		selector.Size = UDim2.fromOffset(500, 570)
		selector.Position = UDim2.fromScale(0.5, 0.5)
		selector.AnchorPoint = Vector2.new(0.5, 0.5)
		selector.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
		selector.BorderSizePixel = 0
		selector.ZIndex = 60
		selector.Parent = keyManager
		addCorner(selector, UDim.new(0, 10))
		local selectorStroke = Instance.new('UIStroke')
		selectorStroke.Color = Color3.fromRGB(215, 215, 215)
		selectorStroke.Parent = selector
		local title = Instance.new('TextLabel')
		title.Size = UDim2.new(1, -76, 0, 62)
		title.Position = UDim2.fromOffset(20, 8)
		title.BackgroundTransparency = 1
		title.Text = 'Select mod to bind'
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextColor3 = uipallet.Text
		title.TextSize = 34
		title.FontFace = uipallet.Font
		title.ZIndex = 61
		title.Parent = selector
		local selectorClose = managerClose:Clone()
		selectorClose.Position = UDim2.new(1, -50, 0, 10)
		selectorClose.ZIndex = 63
		selectorClose.Parent = selector
		selectorClose.MouseButton1Click:Connect(closeSelector)
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
		search.ZIndex = 61
		search.Parent = selector
		local line = Instance.new('Frame')
		line.Size = UDim2.new(1, -58, 0, 1)
		line.Position = UDim2.fromOffset(29, 114)
		line.BackgroundColor3 = Color3.fromRGB(172, 172, 172)
		line.BorderSizePixel = 0
		line.ZIndex = 61
		line.Parent = selector
		local list = Instance.new('ScrollingFrame')
		list.Size = UDim2.new(1, -42, 1, -144)
		list.Position = UDim2.fromOffset(21, 130)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 2
		list.ScrollBarImageColor3 = uipallet.Accent
		list.CanvasSize = UDim2.new()
		list.ZIndex = 61
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
			row.ZIndex = 62
			row.Parent = list
			row.MouseButton1Click:Connect(function()
				callback()
				closeSelector()
				reopen()
			end)
			table.insert(rows, row)
		end
		addChoice('Click GUI', function()
			mainapi.Categories.TopBar.Options.Bind:SetBind({key})
		end)
		eachBindableModule(function(name, module)
			if module.Category ~= 'GUI' and not module.SettingsOnly then
				addChoice(name, function() module:SetBind({key}) end)
			end
		end)
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
		details.Position = UDim2.fromOffset(math.clamp(point.X - 35, 12, 830), math.clamp(point.Y + 52, 75, 118))
		details.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
		details.BorderSizePixel = 0
		details.ZIndex = 50
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
		title.ZIndex = 51
		title.Parent = details
		local divider = Instance.new('Frame')
		divider.Size = UDim2.new(1, -36, 0, 1)
		divider.Position = UDim2.fromOffset(18, 61)
		divider.BackgroundColor3 = Color3.fromRGB(228, 228, 228)
		divider.BorderSizePixel = 0
		divider.ZIndex = 51
		divider.Parent = details
		local assigned = Instance.new('ScrollingFrame')
		assigned.Size = UDim2.new(1, -28, 1, -120)
		assigned.Position = UDim2.fromOffset(14, 72)
		assigned.BackgroundTransparency = 1
		assigned.BorderSizePixel = 0
		assigned.ScrollBarThickness = 0
		assigned.CanvasSize = UDim2.new()
		assigned.ZIndex = 51
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
			row.ZIndex = 52
			row.Parent = assigned
			local label = title:Clone()
			label.Size = UDim2.new(1, -42, 0, 27)
			label.Position = UDim2.fromOffset(3, 0)
			label.Text = name
			label.TextSize = 19
			label.ZIndex = 53
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
			removeButton.ZIndex = 54
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
		eachBindableModule(function(name, module)
			if moduleUsesKey(module, key) then
				assignment(name, module.Category, function() module:SetBind({}) end)
			end
		end)
		local add = Instance.new('TextButton')
		add.Size = UDim2.fromOffset(78, 43)
		add.Position = UDim2.new(1, -92, 1, -52)
		add.BackgroundTransparency = 1
		add.Text = 'Add'
		add.TextColor3 = Color3.fromRGB(54, 158, 218)
		add.TextSize = 24
		add.FontFace = uipallet.Font
		add.ZIndex = 53
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
		row.ZIndex = 42
		row.Parent = keyboard
		local rowList = Instance.new('UIListLayout')
		rowList.FillDirection = Enum.FillDirection.Horizontal
		rowList.Padding = UDim.new(0, 7)
		rowList.SortOrder = Enum.SortOrder.LayoutOrder
		rowList.Parent = row
		for keyIndex, data in rowData do
			local keyButton = Instance.new('TextButton')
			keyButton.Name = data[1]
			keyButton.LayoutOrder = keyIndex
			keyButton.Size = UDim2.fromOffset(60 * (data[3] or 1), 60)
			keyButton.BackgroundColor3 = Color3.fromRGB(238, 238, 238)
			keyButton.BorderSizePixel = 0
			keyButton.AutoButtonColor = false
			keyButton.Text = data[2]
			keyButton.TextColor3 = Color3.fromRGB(119, 119, 119)
			keyButton.TextSize = 19
			keyButton.FontFace = uipallet.Font
			keyButton.ZIndex = 43
			keyButton.Parent = row
			addCorner(keyButton, UDim.new(0, 7))
			local stroke = Instance.new('UIStroke')
			stroke.Color = Color3.fromRGB(218, 218, 218)
			stroke.Thickness = 1
			stroke.Transparency = 0.35
			stroke.Parent = keyButton
			keyButton.MouseButton1Click:Connect(function() showKeyDetails(data[1], keyButton) end)
		end
	end

	local function openKeyManager()
		closeSelector()
		if details then details:Destroy(); details = nil end
		mainapi:ShowJelloModal(keyManager)
	end
	mainapi.Categories.Main:CreateModule({
		Name = 'Keybind Manager',
		SettingsOnly = true,
		Action = openKeyManager,
		Tooltip = 'Assign modules to keyboard keys'
	})
	managerClose.MouseButton1Click:Connect(function()
		closeSelector()
		mainapi:HideJelloModal(keyManager)
	end)

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

	for componentName, component in components do
		categoryapi['Create'..componentName] = function(_, settings)
			local client = mainapi.ClientSettings
			if client and client['Create'..componentName] then
				return client['Create'..componentName](client, settings)
			end
			return component(settings, bar, categoryapi)
		end
	end

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
					mainapi:SetClickGUIVisible(false, true)
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
							mainapi:SetClickGUIVisible(true, true)
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
				if object.Type == 'Overlay' and object.Button and v.Enabled ~= nil and v.Enabled ~= object.Button.Enabled then
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
				if v.Position and object.Type == 'Overlay' and i ~= 'Text GUI' then
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
			if object.Type == 'Overlay' and object.Button and (v.Enabled or false) ~= object.Button.Enabled then
				object.Button:Toggle()
			end
			if v.List and (#object.List > 0 or #v.List > 0) then
				object.List = v.List or {}
				object.ListEnabled = v.ListEnabled or {}
				object:ChangeValue()
			end
			if v.Position and object.Type == 'Overlay' and i ~= 'Text GUI' then
				object.Object.Position = UDim2.fromOffset(v.Position.X or 0, v.Position.Y or 0)
			end
		end

		for i, v in savedata.Modules do
			local object = self.Modules[i]
			if not object then continue end
			if object.SettingsOnly then continue end
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
			object:SetBind(v.Bind or {})
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
			self:SetClickGUIVisible(not self.ClickGUIOpen)
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
		if v.SettingsOnly then continue end
		savedata.Modules[i] = {
			Enabled = v.Enabled,
			Bind = typeof(v.Bind) == 'Instance' and {Mobile = true, X = v.Bind.Position.X.Offset, Y = v.Bind.Position.Y.Offset} or v.Bind,
			Options = mainapi:SaveOptions(v, true)
		}
	end

	for i, v in self.Legit.Modules do
		savedata.Legit[i] = {
			Enabled = v.Enabled,
			Bind = v.Bind,
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
local jelloCategoryWidth = 146
local jelloCategoryHeaderHeight = 28
local jelloCategoryBodyHeight = 224
local jelloCategoryRowHeight = 22
local jelloCategoryTop = 112
local jelloCategoryBottom = jelloCategoryTop + jelloCategoryHeaderHeight + jelloCategoryBodyHeight + 14
local jelloCategoryLayout = {
	-- Match Sigma Jello's fixed 4 x 2 ordering instead of adapting the
	-- layout to the order categories happen to be registered in Roblox.
	Legit = {Position = UDim2.fromOffset(64, jelloCategoryTop), Title = 'Player'},
	Combat = {Position = UDim2.fromOffset(222, jelloCategoryTop), Title = 'Combat'},
	Blatant = {Position = UDim2.fromOffset(380, jelloCategoryTop), Title = 'Movement'},
	Inventory = {Position = UDim2.fromOffset(538, jelloCategoryTop), Title = 'Item'},
	GUI = {Position = UDim2.fromOffset(64, jelloCategoryBottom), Title = 'Gui'},
	World = {Position = UDim2.fromOffset(222, jelloCategoryBottom), Title = 'World'},
	Utility = {Position = UDim2.fromOffset(380, jelloCategoryBottom), Title = 'Misc'},
	Render = {Position = UDim2.fromOffset(538, jelloCategoryBottom), Title = 'Render'}
}
local jelloHUDCount = 0

local function createJelloCategory(api, categorysettings, legit)
	local categoryapi = {
		Type = 'Category',
		Expanded = true,
		Options = {},
		Modules = legit and {} or nil
	}
	local moduleStore = legit and categoryapi.Modules or api.Modules
	local layout = jelloCategoryLayout[categorysettings.Name] or {
		Position = UDim2.fromOffset(696, jelloCategoryTop),
		Title = categorysettings.Name
	}

	local window = Instance.new('Frame')
	window.Name = categorysettings.Name..'Category'
	window.Size = UDim2.fromOffset(jelloCategoryWidth, jelloCategoryHeaderHeight)
	window.Position = layout.Position
	window.BackgroundColor3 = Color3.fromRGB(232, 232, 232)
	window.BorderSizePixel = 0
	window.Visible = true
	window.ClipsDescendants = false
	window.Parent = clickgui

	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.new(1, -18, 1, 0)
	title.Position = UDim2.fromOffset(10, 0)
	title.BackgroundTransparency = 1
	title.Text = layout.Title
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(125, 125, 125)
	title.TextSize = 15
	title.FontFace = uipallet.Font
	title.Parent = window

	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 0, jelloCategoryBodyHeight)
	children.Position = UDim2.fromOffset(0, jelloCategoryHeaderHeight)
	children.BackgroundColor3 = Color3.fromRGB(247, 247, 247)
	children.BorderSizePixel = 0
	children.Visible = true
	children.ScrollBarThickness = 0
	children.CanvasSize = UDim2.new()
	children.Parent = window
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
			Category = categorysettings.Name,
			SettingsOnly = modulesettings.SettingsOnly == true or type(modulesettings.Action) == 'function'
		}
		modulesettings.Function = modulesettings.Function or function() end
		addMaid(moduleapi)

		local modulebutton = Instance.new('TextButton')
		modulebutton.Name = modulesettings.Name
		modulebutton.Size = UDim2.new(1, 0, 0, jelloCategoryRowHeight)
		modulebutton.BackgroundColor3 = Color3.fromRGB(247, 247, 247)
		modulebutton.BorderSizePixel = 0
		modulebutton.AutoButtonColor = false
		modulebutton.Text = ''
		modulebutton.Parent = children
		local moduleLabel = Instance.new('TextLabel')
		moduleLabel.Name = 'Label'
		moduleLabel.Size = UDim2.new(1, -18, 1, 0)
		moduleLabel.Position = UDim2.fromOffset(10, 0)
		moduleLabel.BackgroundTransparency = 1
		moduleLabel.Text = modulesettings.Name
		moduleLabel.TextXAlignment = Enum.TextXAlignment.Left
		moduleLabel.TextColor3 = Color3.fromRGB(72, 72, 72)
		moduleLabel.TextSize = 13
		moduleLabel.FontFace = uipallet.Font
		moduleLabel.Parent = modulebutton
		local accent = Instance.new('Frame')
		accent.Name = 'Accent'
		accent.Size = UDim2.fromScale(1, 1)
		accent.BackgroundColor3 = uipallet.Accent
		accent.BackgroundTransparency = 1
		accent.BorderSizePixel = 0
		accent.Visible = false
		accent.Parent = modulebutton
		accent.ZIndex = modulebutton.ZIndex
		moduleLabel.ZIndex = accent.ZIndex + 1
		local dots = Instance.new('Frame')
		dots.Name = 'Dots'
		dots.Size = UDim2.fromOffset(1, 1)
		dots.BackgroundTransparency = 1
		dots.Visible = false
		dots.Parent = modulebutton

		local settingswindow = Instance.new('CanvasGroup')
		settingswindow.Name = modulesettings.Name..'Settings'
		settingswindow.Size = UDim2.fromOffset(520, 570)
		settingswindow.Position = UDim2.fromScale(0.5, 0.5)
		settingswindow.AnchorPoint = Vector2.new(0.5, 0.5)
		settingswindow.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
		settingswindow.BorderSizePixel = 0
		settingswindow.Visible = false
		settingswindow.ZIndex = 41
		settingswindow.Parent = modalBackdrop
		addCorner(settingswindow, UDim.new(0, 7))
		local stroke = Instance.new('UIStroke')
		stroke.Color = Color3.fromRGB(214, 214, 214)
		stroke.Thickness = 1
		stroke.Transparency = 0.3
		stroke.Parent = settingswindow
		local settingsTitle = Instance.new('TextLabel')
		settingsTitle.Size = UDim2.new(1, -76, 0, 44)
		settingsTitle.Position = UDim2.fromOffset(24, 9)
		settingsTitle.BackgroundTransparency = 1
		settingsTitle.Text = modulesettings.Name
		settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
		settingsTitle.TextColor3 = Color3.fromRGB(33, 33, 33)
		settingsTitle.TextSize = 30
		settingsTitle.FontFace = uipallet.Font
		settingsTitle.ZIndex = 42
		settingsTitle.Parent = settingswindow
		local description = settingsTitle:Clone()
		description.Size = UDim2.new(1, -52, 0, 28)
		description.Position = UDim2.fromOffset(25, 50)
		description.Text = modulesettings.Tooltip or (modulesettings.SettingsOnly and 'Jello client settings' or 'Configure '..modulesettings.Name)
		description.TextColor3 = uipallet.Muted
		description.TextSize = 14
		description.TextWrapped = true
		description.Parent = settingswindow
		local close = Instance.new('TextButton')
		close.Size = UDim2.fromOffset(38, 38)
		close.Position = UDim2.new(1, -48, 0, 8)
		close.BackgroundTransparency = 1
		close.Text = '×'
		close.TextColor3 = uipallet.Muted
		close.TextSize = 27
		close.FontFace = uipallet.Font
		close.ZIndex = 44
		close.Parent = settingswindow
		local settingschildren = Instance.new('ScrollingFrame')
		settingschildren.Name = 'Children'
		settingschildren.Size = UDim2.new(1, -42, 1, -92)
		settingschildren.Position = UDim2.fromOffset(21, 82)
		settingschildren.BackgroundTransparency = 1
		settingschildren.BorderSizePixel = 0
		settingschildren.ScrollBarThickness = 2
		settingschildren.ScrollBarImageColor3 = uipallet.Accent
		settingschildren.CanvasSize = UDim2.new()
		settingschildren.ZIndex = 42
		settingschildren.Parent = settingswindow
		local settingslist = Instance.new('UIListLayout')
		settingslist.SortOrder = Enum.SortOrder.LayoutOrder
		settingslist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		settingslist.Padding = UDim.new(0, 1)
		settingslist.Parent = settingschildren
		moduleapi.Children = settingschildren
		moduleapi.SettingsChildren = settingschildren
		moduleapi.Settings = settingswindow
		if legit then
			moduleapi.Children = nil
			if modulesettings.Size then
				jelloHUDCount += 1
				local hud = Instance.new('Frame')
				hud.Name = modulesettings.Name..'HUD'
				hud.Size = modulesettings.Size
				hud.Position = UDim2.fromOffset(18 + (((jelloHUDCount - 1) % 6) * 122), 90 + (math.floor((jelloHUDCount - 1) / 6) * 190))
				hud.BackgroundTransparency = 1
				hud.Visible = false
				hud.Parent = scaledgui
				makeDraggable(hud, clickgui)
				moduleapi.Children = hud
				moduleapi.HUD = hud
				api:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
					if hud.Parent then hud.Visible = moduleapi.Enabled and not clickgui.Visible end
				end))
			end
		end

		function moduleapi:SetBind(value, mouse)
			value = type(value) == 'table' and value or {}
			local mobile = type(value.Mobile) == 'table' and value.Mobile or value.Mobile == true and value
			if mobile and type(mobile.X) == 'number' and type(mobile.Y) == 'number' then
				createMobileButton(moduleapi, Vector2.new(mobile.X, mobile.Y))
				return
			end
			self.Bind = bindKeys(value)
		end

		local function renderEnabled(animated)
			local background = moduleapi.Enabled and uipallet.Accent or Color3.fromRGB(247, 247, 247)
			local textColor = moduleapi.Enabled and Color3.new(1, 1, 1) or Color3.fromRGB(72, 72, 72)
			local position = UDim2.fromOffset(moduleapi.Enabled and 14 or 10, 0)
			accent.Visible = moduleapi.Enabled
			if animated then
				tweenService:Create(modulebutton, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = background}):Play()
				tweenService:Create(moduleLabel, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = position,
					TextColor3 = textColor
				}):Play()
			else
				modulebutton.BackgroundColor3 = background
				moduleLabel.Position = position
				moduleLabel.TextColor3 = textColor
			end
		end

		function moduleapi:Toggle(multiple)
			if self.SettingsOnly then
				if modulesettings.Action then
					modulesettings.Action()
				else
					api:ShowJelloModal(settingswindow)
				end
				return
			end
			if api.ThreadFix then setthreadidentity(8) end
			self.Enabled = not self.Enabled
			renderEnabled(true)
			if self.HUD then self.HUD.Visible = self.Enabled and not clickgui.Visible end
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

		local function openSettings()
			if modulesettings.Action then
				modulesettings.Action()
				return
			end
			if modulesettings.Special and not modulesettings.SettingsOnly then return end
			api:ShowJelloModal(settingswindow)
		end
		moduleapi.OpenSettings = openSettings
		close.MouseButton1Click:Connect(function() api:HideJelloModal(settingswindow) end)
		modulebutton.MouseButton1Click:Connect(function()
			if moduleapi.SettingsOnly then openSettings() else moduleapi:Toggle() end
		end)
		modulebutton.MouseButton2Click:Connect(openSettings)
		modulebutton.MouseEnter:Connect(function()
			if not moduleapi.Enabled then
				tweenService:Create(modulebutton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(239, 239, 239)}):Play()
			end
		end)
		modulebutton.MouseLeave:Connect(function() renderEnabled(true) end)
		settingslist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			settingschildren.CanvasSize = UDim2.fromOffset(0, settingslist.AbsoluteContentSize.Y + 12)
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
		renderEnabled(false)
		return moduleapi
	end

	categoryapi.CreateModule = function(_, settings) return createModule(settings) end
	for componentName, component in components do
		categoryapi['Create'..componentName] = function(_, settings)
			return component(settings, children, categoryapi)
		end
	end
	function categoryapi:Expand()
		self.Expanded = true
		children.Visible = true
	end
	windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		local contentHeight = windowlist.AbsoluteContentSize.Y
		children.CanvasSize = UDim2.fromOffset(0, contentHeight)
	end)
	categoryapi.Object = window
	return categoryapi
end

mainapi.CreateCategory = function(self, categorysettings)
	if categorysettings.Name == 'Minigames' and self.Categories.Utility then
		self.Categories.Minigames = self.Categories.Utility
		return self.Categories.Utility
	end
	local categoryapi = createJelloCategory(self, categorysettings, false)
	if categorysettings.Name == 'GUI' then
		self.Categories.Main = categoryapi
	else
		self.Categories[categorysettings.Name] = categoryapi
	end
	return categoryapi
end

mainapi.CreateLegit = function(self, categorysettings)
	local categoryapi = createJelloCategory(self, categorysettings, true)
	self.Categories[categorysettings.Name] = categoryapi
	return categoryapi
end

-- Jello treats overlays as ordinary modules with a right-click settings sheet.
-- Their rendered objects live outside the Click GUI and are hidden while the
-- menu is open, matching Sigma's separate HUD/menu behaviour.
mainapi.CreateOverlay = function(self, categorysettings)
	local routedCategory = ({
		['Session Info'] = 'Render',
		Radar = 'Render',
		['Target Info'] = 'Render'
	})[categorysettings.Name] or 'GUI'
	local parentCategory = self.Categories[routedCategory] or self.Categories.Main
	local overlayapi
	local hud
	local moduleapi = parentCategory:CreateModule({
		Name = categorysettings.Name,
		Tooltip = categorysettings.Tooltip or 'Configure '..categorysettings.Name,
		Function = function(enabled)
			if hud then hud.Visible = enabled and not mainapi.ClickGUIOpen end
			if not enabled and overlayapi then
				for _, connection in overlayapi.Connections do
					pcall(function() connection:Disconnect() end)
				end
				table.clear(overlayapi.Connections)
			end
			if categorysettings.Function then task.spawn(categorysettings.Function, enabled) end
		end
	})

	hud = Instance.new('Frame')
	hud.Name = categorysettings.Name..'HUD'
	hud.BackgroundTransparency = 1
	hud.BorderSizePixel = 0
	hud.Visible = false
	hud.Parent = scaledgui
	if categorysettings.Name == 'Text GUI' then
		hud.Size = UDim2.fromScale(1, 1)
		hud.Position = UDim2.fromOffset(0, 0)
	else
		hud.Size = UDim2.fromOffset(categorysettings.WindowSize or 246, 320)
		hud.Position = UDim2.fromOffset(24, 108)
	end

	local customchildren = Instance.new('Frame')
	customchildren.Name = 'CustomChildren'
	customchildren.Size = UDim2.fromScale(1, 1)
	customchildren.BackgroundTransparency = 1
	customchildren.Parent = hud

	overlayapi = {
		Type = 'Overlay',
		Expanded = true,
		Pinned = false,
		Button = moduleapi,
		Options = moduleapi.Options,
		Object = hud,
		Children = customchildren
	}
	addMaid(overlayapi)
	function overlayapi:Pin()
		self.Pinned = false
	end
	function overlayapi:Expand()
		self.Expanded = true
	end
	function overlayapi:Update()
		hud.Visible = moduleapi.Enabled and not mainapi.ClickGUIOpen
	end

	moduleapi.OriginalChildren = moduleapi.SettingsChildren
	moduleapi.Children = customchildren
	moduleapi.Button = moduleapi
	moduleapi.Overlay = overlayapi
	self.Categories[categorysettings.Name] = overlayapi
	self:Clean(clickgui:GetPropertyChangedSignal('Visible'):Connect(function()
		overlayapi:Update()
	end))
	return moduleapi
end

-- Friends and Profiles use the same modal sheet as module settings instead of
-- spawning the narrow legacy windows. Targets remains a data-only list because
-- target selection belongs to module settings in Jello.
mainapi.CreateCategoryList = function(self, categorysettings)
	local categoryapi = {
		Type = 'CategoryList',
		Expanded = true,
		List = {},
		ListEnabled = {},
		Objects = {},
		Options = {},
		Profiles = categorysettings.Profiles == true,
		Selected = nil
	}
	categorysettings.Function = categorysettings.Function or function() end

	local hiddenObject = Instance.new('Frame')
	hiddenObject.Name = categorysettings.Name..'DataOnly'
	hiddenObject.Size = UDim2.fromOffset(1, 1)
	hiddenObject.BackgroundTransparency = 1
	hiddenObject.Visible = false
	hiddenObject.Parent = clickgui
	categoryapi.Object = hiddenObject

	local moduleapi
	local listCard
	local rowsHolder
	local rowsLayout
	local addValue
	if not categorysettings.Hidden then
		moduleapi = self.Categories.Main:CreateModule({
			Name = categorysettings.Name,
			SettingsOnly = true,
			Tooltip = categorysettings.Profiles and 'Create, load, and bind portable profiles' or 'Manage '..categorysettings.Name:lower()
		})
		categoryapi.Button = moduleapi
		categoryapi.Options = moduleapi.Options
		categoryapi.Object = moduleapi.Object

		listCard = Instance.new('Frame')
		listCard.Name = categorysettings.Name..'List'
		listCard.Size = UDim2.new(1, -12, 0, 56)
		listCard.BackgroundTransparency = 1
		listCard.LayoutOrder = -100
		listCard.ZIndex = moduleapi.SettingsChildren.ZIndex + 1
		listCard.Parent = moduleapi.SettingsChildren

		local addRow = Instance.new('Frame')
		addRow.Size = UDim2.new(1, 0, 0, 44)
		addRow.BackgroundTransparency = 1
		addRow.ZIndex = listCard.ZIndex + 1
		addRow.Parent = listCard
		local addBackground = Instance.new('Frame')
		addBackground.Size = UDim2.new(1, -70, 0, 36)
		addBackground.Position = UDim2.fromOffset(0, 4)
		addBackground.BackgroundColor3 = Color3.fromRGB(242, 242, 242)
		addBackground.BorderSizePixel = 0
		addBackground.ZIndex = addRow.ZIndex + 1
		addBackground.Parent = addRow
		addCorner(addBackground, UDim.new(0, 5))
		addValue = Instance.new('TextBox')
		addValue.Size = UDim2.new(1, -20, 1, 0)
		addValue.Position = UDim2.fromOffset(10, 0)
		addValue.BackgroundTransparency = 1
		addValue.Text = ''
		addValue.PlaceholderText = categorysettings.Placeholder or 'Add entry...'
		addValue.PlaceholderColor3 = Color3.fromRGB(169, 169, 169)
		addValue.TextColor3 = uipallet.Text
		addValue.TextXAlignment = Enum.TextXAlignment.Left
		addValue.TextSize = 17
		addValue.FontFace = uipallet.Font
		addValue.ClearTextOnFocus = false
		addValue.ZIndex = addBackground.ZIndex + 1
		addValue.Parent = addBackground
		local addButton = Instance.new('TextButton')
		addButton.Size = UDim2.fromOffset(62, 40)
		addButton.Position = UDim2.new(1, -62, 0, 2)
		addButton.BackgroundTransparency = 1
		addButton.Text = 'Add'
		addButton.TextColor3 = Color3.fromRGB(45, 151, 215)
		addButton.TextSize = 19
		addButton.FontFace = uipallet.Font
		addButton.ZIndex = addRow.ZIndex + 2
		addButton.Parent = addRow

		rowsHolder = Instance.new('Frame')
		rowsHolder.Size = UDim2.new(1, 0, 0, 0)
		rowsHolder.Position = UDim2.fromOffset(0, 52)
		rowsHolder.BackgroundTransparency = 1
		rowsHolder.ZIndex = listCard.ZIndex + 1
		rowsHolder.Parent = listCard
		rowsLayout = Instance.new('UIListLayout')
		rowsLayout.Padding = UDim.new(0, 3)
		rowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rowsLayout.Parent = rowsHolder
		local function resizeList()
			rowsHolder.Size = UDim2.new(1, 0, 0, rowsLayout.AbsoluteContentSize.Y)
			listCard.Size = UDim2.new(1, -12, 0, 58 + rowsLayout.AbsoluteContentSize.Y)
		end
		rowsLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(resizeList)

		local function submit()
			local value = addValue.Text:match('^%s*(.-)%s*$')
			if value ~= '' then categoryapi:ChangeValue(value); addValue.Text = '' end
		end
		addButton.MouseButton1Click:Connect(submit)
		addValue.FocusLost:Connect(function(enter) if enter then submit() end end)
	end

	function categoryapi:GetValue(name)
		for index, profile in mainapi.Profiles do
			if profile.Name == name then return index end
		end
	end

	local function clearRows()
		for _, object in categoryapi.Objects do object:Destroy() end
		table.clear(categoryapi.Objects)
		categoryapi.Selected = nil
	end

	local function makeRow(name, selected)
		local row = Instance.new('Frame')
		row.Name = name
		row.Size = UDim2.new(1, -4, 0, 40)
		row.BackgroundColor3 = selected and Color3.fromRGB(226, 244, 252) or Color3.fromRGB(248, 248, 248)
		row.BorderSizePixel = 0
		row.ZIndex = rowsHolder.ZIndex + 1
		row.Parent = rowsHolder
		addCorner(row, UDim.new(0, 4))
		local labelButton = Instance.new('TextButton')
		labelButton.Name = 'Title'
		labelButton.Size = UDim2.new(1, -48, 1, 0)
		labelButton.Position = UDim2.fromOffset(12, 0)
		labelButton.BackgroundTransparency = 1
		labelButton.Text = name
		labelButton.TextXAlignment = Enum.TextXAlignment.Left
		labelButton.TextColor3 = selected and Color3.fromRGB(35, 143, 205) or uipallet.Text
		labelButton.TextSize = 17
		labelButton.FontFace = uipallet.Font
		labelButton.ZIndex = row.ZIndex + 1
		labelButton.Parent = row
		local remove = Instance.new('TextButton')
		remove.Name = 'Remove'
		remove.Size = UDim2.fromOffset(36, 36)
		remove.Position = UDim2.new(1, -38, 0, 2)
		remove.BackgroundTransparency = 1
		remove.Text = '×'
		remove.TextColor3 = Color3.fromRGB(226, 105, 105)
		remove.TextSize = 22
		remove.FontFace = uipallet.Font
		remove.ZIndex = row.ZIndex + 2
		remove.Parent = row
		table.insert(categoryapi.Objects, row)
		return row, labelButton, remove
	end

	function categoryapi:ChangeValue(value, silent)
		if value and value ~= '' then
			if self.Profiles then
				local index = self:GetValue(value)
				if index then
					if value ~= 'default' and value ~= mainapi.Profile then
						table.remove(mainapi.Profiles, index)
						local canonical = 'newvape/profiles/'..value..mainapi.Place..'.txt'
						local portable = 'newvape/profiles/'..value..'.txt'
						if delfile and isfile(canonical) then delfile(canonical) end
						if delfile and isfile(portable) then delfile(portable) end
					end
				else
					table.insert(mainapi.Profiles, {Name = value, Bind = {}})
				end
			else
				local index = table.find(self.List, value)
				if index then
					table.remove(self.List, index)
					local enabledIndex = table.find(self.ListEnabled, value)
					if enabledIndex then table.remove(self.ListEnabled, enabledIndex) end
				else
					table.insert(self.List, value)
					table.insert(self.ListEnabled, value)
				end
			end
		end

		if not silent then categorysettings.Function() end
		if not rowsHolder then return end
		clearRows()
		local source = self.Profiles and mainapi.Profiles or self.List
		for _, entry in source do
			local name = self.Profiles and entry.Name or entry
			local selected = self.Profiles and name == mainapi.Profile
			local row, labelButton, remove = makeRow(name, selected)
			if selected then self.Selected = row end
			if self.Profiles then
				labelButton.MouseButton1Click:Connect(function()
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						labelButton.Text = 'Press a key'
						mainapi.Binding = {
							Bind = entry.Bind,
							SetBind = function(_, keys)
								entry.Bind = bindKeys(keys)
								labelButton.Text = name
							end
						}
						return
					end
					mainapi:Save(name)
					mainapi:Load(true, name)
				end)
				remove.MouseButton1Click:Connect(function()
					if name ~= 'default' and name ~= mainapi.Profile then self:ChangeValue(name) end
				end)
			else
				local function refreshEnabled()
					local enabled = table.find(self.ListEnabled, name) ~= nil
					row.BackgroundColor3 = enabled and Color3.fromRGB(226, 244, 252) or Color3.fromRGB(248, 248, 248)
					labelButton.TextColor3 = enabled and Color3.fromRGB(35, 143, 205) or uipallet.Text
				end
				refreshEnabled()
				labelButton.MouseButton1Click:Connect(function()
					local index = table.find(self.ListEnabled, name)
					if index then table.remove(self.ListEnabled, index) else table.insert(self.ListEnabled, name) end
					refreshEnabled()
					categorysettings.Function()
				end)
				remove.MouseButton1Click:Connect(function() self:ChangeValue(name) end)
			end
		end
		rowsHolder.Size = UDim2.new(1, 0, 0, rowsLayout.AbsoluteContentSize.Y)
		listCard.Size = UDim2.new(1, -12, 0, 58 + rowsLayout.AbsoluteContentSize.Y)
	end

	function categoryapi:Expand()
		self.Expanded = true
		if moduleapi then moduleapi:OpenSettings() end
	end

	if moduleapi then
		for componentName in components do
			categoryapi['Create'..componentName] = function(_, settings)
				return moduleapi['Create'..componentName](moduleapi, settings)
			end
		end
	end
	self.Categories[categorysettings.Name] = categoryapi
	categoryapi:ChangeValue(nil, true)
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
clickgui = Instance.new('CanvasGroup')
clickgui.Name = 'ClickGui'
clickgui.Size = UDim2.fromScale(1, 1)
clickgui.Position = UDim2.fromScale(0.5, 0.5)
clickgui.AnchorPoint = Vector2.new(0.5, 0.5)
clickgui.BackgroundTransparency = 1
clickgui.GroupTransparency = 0
clickgui.Visible = false
clickgui.Parent = scaledgui
clickguiScale = Instance.new('UIScale')
clickguiScale.Name = 'OpenScale'
clickguiScale.Scale = 1
clickguiScale.Parent = clickgui
local jelloBackdrop = Instance.new('Frame')
jelloBackdrop.Name = 'Backdrop'
jelloBackdrop.Size = UDim2.fromScale(1, 1)
jelloBackdrop.BackgroundColor3 = Color3.fromRGB(8, 13, 18)
jelloBackdrop.BackgroundTransparency = 0.66
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
	NumberSequenceKeypoint.new(0, 0.58),
	NumberSequenceKeypoint.new(0.5, 0.75),
	NumberSequenceKeypoint.new(1, 0.62)
})
backdropGradient.Parent = jelloBackdrop
local compass = Instance.new('TextLabel')
compass.Name = 'Compass'
compass.Size = UDim2.fromOffset(410, 30)
compass.Position = UDim2.new(0.5, -205, 0, 22)
compass.BackgroundTransparency = 1
compass.Text = 'N     195     210     NE     240     255     E'
compass.TextColor3 = Color3.fromRGB(215, 215, 215)
compass.TextTransparency = 0.28
compass.TextSize = 12
compass.FontFace = uipallet.Font
compass.Parent = clickgui
modalBackdrop = Instance.new('TextButton')
modalBackdrop.Name = 'ModalBackdrop'
modalBackdrop.Size = UDim2.fromScale(1, 1)
modalBackdrop.BackgroundColor3 = Color3.fromRGB(28, 30, 34)
modalBackdrop.BackgroundTransparency = 1
modalBackdrop.BorderSizePixel = 0
modalBackdrop.Text = ''
modalBackdrop.AutoButtonColor = false
modalBackdrop.Active = true
modalBackdrop.Modal = true
modalBackdrop.Visible = false
modalBackdrop.ZIndex = 40
modalBackdrop.Parent = clickgui
mainapi.JelloModalLayer = modalBackdrop
mainapi.ActiveJelloModal = nil

local function getOpenScale(panel)
	local panelScale = panel:FindFirstChild('OpenScale')
	if not panelScale then
		panelScale = Instance.new('UIScale')
		panelScale.Name = 'OpenScale'
		panelScale.Parent = panel
	end
	return panelScale
end

function mainapi:ShowJelloModal(panel)
	if not panel then return end
	if self.ActiveJelloModal and self.ActiveJelloModal ~= panel then
		self.ActiveJelloModal.Visible = false
	end
	self.ActiveJelloModal = panel
	modalBackdrop.Visible = true
	modalBackdrop.BackgroundTransparency = 1
	panel.Visible = true
	if panel:IsA('CanvasGroup') then panel.GroupTransparency = 1 end
	local panelScale = getOpenScale(panel)
	panelScale.Scale = 0.94
	tweenService:Create(modalBackdrop, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.48
	}):Play()
	tweenService:Create(panelScale, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Scale = 1
	}):Play()
	if panel:IsA('CanvasGroup') then
		tweenService:Create(panel, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			GroupTransparency = 0
		}):Play()
	end
end

function mainapi:HideJelloModal(panel, instant)
	panel = panel or self.ActiveJelloModal
	if not panel then
		modalBackdrop.Visible = false
		return
	end
	if instant then
		panel.Visible = false
		modalBackdrop.Visible = false
		if self.ActiveJelloModal == panel then self.ActiveJelloModal = nil end
		return
	end
	local panelScale = getOpenScale(panel)
	tweenService:Create(modalBackdrop, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		BackgroundTransparency = 1
	}):Play()
	tweenService:Create(panelScale, TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Scale = 0.96
	}):Play()
	if panel:IsA('CanvasGroup') then
		tweenService:Create(panel, TweenInfo.new(0.12), {GroupTransparency = 1}):Play()
	end
	task.delay(0.14, function()
		if self.ActiveJelloModal == panel then
			panel.Visible = false
			modalBackdrop.Visible = false
			self.ActiveJelloModal = nil
		end
	end)
end

modalBackdrop.MouseButton1Click:Connect(function()
	mainapi:HideJelloModal()
end)
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
scale.Scale = math.clamp(gui.AbsoluteSize.Y / 900, 1, 1.08)
scale.Parent = scaledgui
mainapi.guiscale = scale
scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)

mainapi:Clean(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
	scale.Scale = math.clamp(gui.AbsoluteSize.Y / 900, 1, 1.08)
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

mainapi.ClickGUIOpen = false
function mainapi:SetClickGUIVisible(visible, instant)
	visible = visible and true or false
	self.ClickGUIOpen = visible
	self:HideJelloModal(nil, true)
	if visible then
		clickgui.Visible = true
		clickgui.GroupTransparency = instant and 0 or 1
		clickguiScale.Scale = instant and 1 or 0.96
		if not instant then
			tweenService:Create(clickgui, TweenInfo.new(0.17, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				GroupTransparency = 0
			}):Play()
			tweenService:Create(clickguiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
		end
	else
		if instant then
			clickgui.Visible = false
		else
			tweenService:Create(clickgui, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				GroupTransparency = 1
			}):Play()
			tweenService:Create(clickguiScale, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Scale = 0.97
			}):Play()
			task.delay(0.15, function()
				if not self.ClickGUIOpen then clickgui.Visible = false end
			end)
		end
	end
	tooltip.Visible = false
	self:UpdateTextGUI(true)
	self:BlurCheck()
end

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
local settingspane = mainapi.Categories.Main:CreateModule({
	Name = 'Client Settings',
	SettingsOnly = true,
	Tooltip = 'Jello interface, profile, and client options'
})
mainapi.ClientSettings = settingspane


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
	Hidden = true,
	Function = function()
		targets.Update:Fire()
	end
})
targets.Update = Instance.new('BindableEvent')
mainapi:Clean(targets.Update)

local topbar = mainapi:CreateBar()
mainapi.Categories.Main.Options = settingspane.Options

mainapi.GUIColor = {
	Hue = 0.55,
	Sat = 0.85,
	Value = 0.9,
	Rainbow = false,
	SetValue = function(self)
		self.Hue = 0.55
		self.Sat = 0.85
		self.Value = 0.9
		self.Rainbow = false
	end
}

local function changedOptions()
	for _, module in mainapi.Modules do
		for _, option in module.Options do
			if option.Type == 'Targets' then
				option.Function()
			end
		end
	end
end

local function createHiddenTargetOption(name, default)
	local optionapi = {
		Type = 'Toggle',
		Enabled = default == true,
		Object = {Visible = false}
	}
	function optionapi:Save(tab)
		tab[name] = {Enabled = self.Enabled}
	end
	function optionapi:Load(tab)
		if type(tab) == 'table' and self.Enabled ~= (tab.Enabled == true) then self:Toggle() end
	end
	function optionapi:Toggle()
		self.Enabled = not self.Enabled
		changedOptions()
	end
	settingspane.Options[name] = optionapi
	return optionapi
end

mainapi.TargetOptions = {
	Players = createHiddenTargetOption('Players', true),
	NPCs = createHiddenTargetOption('NPCs', false),
	Invisible = createHiddenTargetOption('Ignore invisible', false),
	Walls = createHiddenTargetOption('Ignore behind walls', false)
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
	Min = 0.7,
	Max = 1.5,
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
	Tooltip = 'Shows the Sigma Jello logo in game',
	Default = true,
	Function = function()
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

local jelloTextColor = Color3.fromRGB(230, 230, 230)
local JelloLabels = {}
local JelloHUDLogo = Instance.new('TextLabel')
JelloHUDLogo.Name = 'SigmaLogo'
JelloHUDLogo.Size = UDim2.fromOffset(190, 38)
JelloHUDLogo.Position = UDim2.fromOffset(14, 42)
JelloHUDLogo.BackgroundTransparency = 1
JelloHUDLogo.Text = 'Sigma'
JelloHUDLogo.TextXAlignment = Enum.TextXAlignment.Left
JelloHUDLogo.TextYAlignment = Enum.TextYAlignment.Top
JelloHUDLogo.TextColor3 = jelloTextColor
JelloHUDLogo.TextSize = 30
JelloHUDLogo.FontFace = uipallet.Font
JelloHUDLogo.Parent = textgui.Children
local JelloHUDSublogo = JelloHUDLogo:Clone()
JelloHUDSublogo.Name = 'JelloSublogo'
JelloHUDSublogo.Size = UDim2.fromOffset(100, 18)
JelloHUDSublogo.Position = UDim2.fromOffset(16, 74)
JelloHUDSublogo.Text = 'Jello'
JelloHUDSublogo.TextColor3 = Color3.fromRGB(205, 205, 205)
JelloHUDSublogo.TextSize = 13
JelloHUDSublogo.Parent = textgui.Children

local JelloLabelHolder = Instance.new('Frame')
JelloLabelHolder.Name = 'ModuleList'
JelloLabelHolder.Size = UDim2.fromOffset(430, 700)
JelloLabelHolder.Position = UDim2.new(1, -18, 0, 44)
JelloLabelHolder.AnchorPoint = Vector2.new(1, 0)
JelloLabelHolder.BackgroundTransparency = 1
JelloLabelHolder.Parent = textgui.Children
VapeTextScale.Parent = JelloLabelHolder
local JelloLabelSorter = Instance.new('UIListLayout')
JelloLabelSorter.HorizontalAlignment = Enum.HorizontalAlignment.Right
JelloLabelSorter.VerticalAlignment = Enum.VerticalAlignment.Top
JelloLabelSorter.SortOrder = Enum.SortOrder.LayoutOrder
JelloLabelSorter.Parent = JelloLabelHolder

function mainapi:UpdateTextGUI(afterload)
	if not afterload and not mainapi.Loaded then return end
	local visible = textgui.Button.Enabled and not mainapi.ClickGUIOpen
	textgui.Overlay.Object.Visible = visible
	JelloHUDLogo.Visible = visible and textguiwatermark.Enabled
	JelloHUDSublogo.Visible = visible and textguiwatermark.Enabled
	JelloLabelHolder.Visible = visible

	for _, label in JelloLabels do label.Object:Destroy() end
	table.clear(JelloLabels)
	if not visible then return end

	local function addTextModule(name, module)
		if not module.Enabled or module.SettingsOnly or module.Category == 'GUI' then return end
		if textguimodules.Enabled and textguimoduleslist and table.find(textguimoduleslist.ListEnabled, name) then return end
		if textguirender.Enabled and module.Category == 'Render' then return end
		local extra = module.ExtraText and module.ExtraText()
		local rendered = name..(extra and " <font color='#AAAAAA'>"..tostring(extra)..'</font>' or '')
		local size = getfontsize(removeTags(rendered), 18, uipallet.Font)
		local holder = Instance.new('Frame')
		holder.Name = name
		holder.Size = UDim2.fromOffset(size.X + 6, size.Y + 3)
		holder.BackgroundTransparency = 1
		holder.Parent = JelloLabelHolder
		if textguishadow.Enabled then
			local shadow = Instance.new('TextLabel')
			shadow.Size = UDim2.fromScale(1, 1)
			shadow.Position = UDim2.fromOffset(1, 1)
			shadow.BackgroundTransparency = 1
			shadow.Text = removeTags(rendered)
			shadow.TextXAlignment = Enum.TextXAlignment.Right
			shadow.TextColor3 = Color3.new()
			shadow.TextTransparency = 0.58
			shadow.TextSize = 18
			shadow.FontFace = uipallet.Font
			shadow.Parent = holder
		end
		local label = Instance.new('TextLabel')
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.Text = rendered
		label.TextXAlignment = Enum.TextXAlignment.Right
		label.TextColor3 = jelloTextColor
		label.TextSize = 18
		label.RichText = true
		label.FontFace = uipallet.Font
		label.Parent = holder
		table.insert(JelloLabels, {Name = name, Object = holder, Text = label, Width = size.X})
	end

	for name, module in mainapi.Modules do
		addTextModule(name, module)
	end
	if mainapi.Legit then
		for name, module in mainapi.Legit.Modules do
			addTextModule(name, module)
		end
	end

	if textguisort.Value == 'Alphabetical' then
		table.sort(JelloLabels, function(a, b) return a.Name < b.Name end)
	else
		table.sort(JelloLabels, function(a, b) return a.Width > b.Width end)
	end
	for order, label in JelloLabels do label.Object.LayoutOrder = order end
end

function mainapi:UpdateModuleColor(button, hue, sat, val, default, rainbowcheck)
	local fixedHue, fixedSat, fixedValue = uipallet.Accent:ToHSV()
	for _, option in button.Options do
		if option.Color then
			option:Color(fixedHue, fixedSat, fixedValue, false)
		end
	end
end

function mainapi:UpdateGUI(hue, sat, val, default)
	if mainapi.Loaded == nil then return end
	mainapi.GUIColor:SetValue()
	for _, v in mainapi.Categories do
		if v.Options then
			for _, option in v.Options do
				if option.Color then option:Color(mainapi.GUIColor.Hue, mainapi.GUIColor.Sat, mainapi.GUIColor.Value, false) end
			end
		end
	end
	for _, button in mainapi.Modules do
		self:UpdateModuleColor(button)
	end
	if mainapi.Legit then
		for _, button in mainapi.Legit.Modules do
			self:UpdateModuleColor(button)
		end
	end
	for _, label in JelloLabels do label.Text.TextColor3 = jelloTextColor end
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
			mainapi:SetClickGUIVisible(not mainapi.ClickGUIOpen)
		end

		local toggled = false
		local function toggleBound(modules)
			for name, module in modules do
				if checkKeybinds(mainapi.HeldKeybinds, module.Bind, inputObj.KeyCode.Name) then
					toggled = true
					if mainapi.ToggleNotifications.Enabled then
						mainapi:CreateNotification('Module Toggled', name.."<font color='#FFFFFF'> has been </font>"..(not module.Enabled and "<font color='#5AFF5A'>Enabled</font>" or "<font color='#FF5A5A'>Disabled</font>").."<font color='#FFFFFF'>!</font>", 0.75)
					end
					module:Toggle(true)
				end
			end
		end
		toggleBound(mainapi.Modules)
		if mainapi.Legit then toggleBound(mainapi.Legit.Modules) end
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
