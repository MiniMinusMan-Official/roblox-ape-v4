local liquidAccent = Color3.fromRGB(70, 119, 255)
local liquidHue, liquidSat, liquidValue = liquidAccent:ToHSV()
local mainapi = {
	Categories = {},
	GUIColor = {
		Hue = liquidHue,
		Sat = liquidSat,
		Value = liquidValue
	},
	HeldKeybinds = {},
	Keybind = {'RightShift'},
	Loaded = false,
	Legit = {Modules = {}},
	Libraries = {},
	Modules = {},
	MultiKeybind = {},
	Place = game.PlaceId,
	Profile = 'default',
	Profiles = {},
	RainbowSpeed = {Value = 1},
	RainbowUpdateSpeed = {Value = 60},
	RainbowTable = {},
	Scale = {Value = 1},
	ThreadFix = setthreadidentity and true or false,
	ToggleNotifications = {},
	Version = '4.18',
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
local mainframe
local mainscale
local sidebar
local categoryholder
local categoryhighlight
local lastSelected
local guiTween
local searchbox
local searchresults
local textgui
local textguiholder
local textguilogo
local bindsmodule
local bindsholder
local scale
local gui

local color = {}
local tween = {
	tweens = {},
	tweenstwo = {}
}
local uipallet = {
	Main = liquidAccent,
	Text = Color3.new(1, 1, 1),
	Panel = Color3.fromRGB(3, 6, 12),
	PanelLight = Color3.fromRGB(8, 12, 19),
	Muted = Color3.fromRGB(143, 148, 158),
	Tween = TweenInfo.new(0.08, Enum.EasingStyle.Linear),
}

local getcustomassets = {
	['newvape/assets/liquidbounce/logo.png'] = 'rbxasset://liquidbounce/logo.png',
	['newvape/assets/liquidbounce/textgui.png'] = 'rbxasset://liquidbounce/textgui.png',
	['newvape/assets/liquidbounce/add.png'] = 'rbxasset://liquidbounce/add.png',
	['newvape/assets/liquidbounce/allowedicon.png'] = 'rbxasset://liquidbounce/allowedicon.png',
	['newvape/assets/liquidbounce/allowedtab.png'] = 'rbxasset://liquidbounce/allowedtab.png',
	['newvape/assets/liquidbounce/back.png'] = 'rbxasset://liquidbounce/back.png',
	['newvape/assets/liquidbounce/blur.png'] = 'rbxasset://liquidbounce/blur.png',
	['newvape/assets/liquidbounce/closemini.png'] = 'rbxasset://liquidbounce/closemini.png',
	['newvape/assets/liquidbounce/colorpreview.png'] = 'rbxasset://liquidbounce/colorpreview.png',
	['newvape/assets/liquidbounce/expandicon.png'] = 'rbxasset://liquidbounce/expandicon.png',
	['newvape/assets/liquidbounce/guislider.png'] = 'rbxasset://liquidbounce/guislider.png',
	['newvape/assets/liquidbounce/guisliderrain.png'] = 'rbxasset://liquidbounce/guisliderrain.png',
	['newvape/assets/liquidbounce/rainbow_1.png'] = 'rbxasset://liquidbounce/rainbow_1.png',
	['newvape/assets/liquidbounce/rainbow_2.png'] = 'rbxasset://liquidbounce/rainbow_2.png',
	['newvape/assets/liquidbounce/rainbow_3.png'] = 'rbxasset://liquidbounce/rainbow_3.png',
	['newvape/assets/liquidbounce/rainbow_4.png'] = 'rbxasset://liquidbounce/rainbow_4.png',
	['newvape/assets/liquidbounce/targetnpc1.png'] = 'rbxasset://liquidbounce/targetnpc1.png',
	['newvape/assets/liquidbounce/targetnpc2.png'] = 'rbxasset://liquidbounce/targetnpc2.png',
	['newvape/assets/liquidbounce/targetplayers1.png'] = 'rbxasset://liquidbounce/targetplayers1.png',
	['newvape/assets/liquidbounce/targetplayers2.png'] = 'rbxasset://liquidbounce/targetplayers2.png',
	['newvape/assets/liquidbounce/targetstab.png'] = 'rbxasset://liquidbounce/targetstab.png',
	['newvape/assets/liquidbounce/combat.png'] = 'rbxasset://liquidbounce/combat.png',
	['newvape/assets/liquidbounce/exploit.png'] = 'rbxasset://liquidbounce/exploit.png',
	['newvape/assets/liquidbounce/fun.png'] = 'rbxasset://liquidbounce/fun.png',
	['newvape/assets/liquidbounce/misc.png'] = 'rbxasset://liquidbounce/misc.png',
	['newvape/assets/liquidbounce/movement.png'] = 'rbxasset://liquidbounce/movement.png',
	['newvape/assets/liquidbounce/player.png'] = 'rbxasset://liquidbounce/player.png',
	['newvape/assets/liquidbounce/render.png'] = 'rbxasset://liquidbounce/render.png',
	['newvape/assets/liquidbounce/settings-expand.png'] = 'rbxasset://liquidbounce/settings-expand.png',
	['newvape/assets/liquidbounce/world.png'] = 'rbxasset://liquidbounce/world.png',
	['newvape/assets/liquidbounce/notification-error.png'] = 'rbxasset://liquidbounce/notification-error.png',
	['newvape/assets/liquidbounce/notification-info.png'] = 'rbxasset://liquidbounce/notification-info.png',
	['newvape/assets/liquidbounce/notification-success.png'] = 'rbxasset://liquidbounce/notification-success.png',
	['newvape/assets/liquidbounce/tabgui-combat-active.png'] = 'rbxasset://liquidbounce/tabgui-combat-active.png',
	['newvape/assets/liquidbounce/tabgui-combat.png'] = 'rbxasset://liquidbounce/tabgui-combat.png',
	['newvape/assets/liquidbounce/tabgui-exploit-active.png'] = 'rbxasset://liquidbounce/tabgui-exploit-active.png',
	['newvape/assets/liquidbounce/tabgui-exploit.png'] = 'rbxasset://liquidbounce/tabgui-exploit.png',
	['newvape/assets/liquidbounce/tabgui-fun-active.png'] = 'rbxasset://liquidbounce/tabgui-fun-active.png',
	['newvape/assets/liquidbounce/tabgui-fun.png'] = 'rbxasset://liquidbounce/tabgui-fun.png',
	['newvape/assets/liquidbounce/tabgui-misc-active.png'] = 'rbxasset://liquidbounce/tabgui-misc-active.png',
	['newvape/assets/liquidbounce/tabgui-misc.png'] = 'rbxasset://liquidbounce/tabgui-misc.png',
	['newvape/assets/liquidbounce/tabgui-movement-active.png'] = 'rbxasset://liquidbounce/tabgui-movement-active.png',
	['newvape/assets/liquidbounce/tabgui-movement.png'] = 'rbxasset://liquidbounce/tabgui-movement.png',
	['newvape/assets/liquidbounce/tabgui-player-active.png'] = 'rbxasset://liquidbounce/tabgui-player-active.png',
	['newvape/assets/liquidbounce/tabgui-player.png'] = 'rbxasset://liquidbounce/tabgui-player.png',
	['newvape/assets/liquidbounce/tabgui-render-active.png'] = 'rbxasset://liquidbounce/tabgui-render-active.png',
	['newvape/assets/liquidbounce/tabgui-render.png'] = 'rbxasset://liquidbounce/tabgui-render.png',
	['newvape/assets/liquidbounce/tabgui-world-active.png'] = 'rbxasset://liquidbounce/tabgui-world-active.png',
	['newvape/assets/liquidbounce/tabgui-world.png'] = 'rbxasset://liquidbounce/tabgui-world.png',
	['newvape/assets/liquidbounce/watermark-lb-logo.png'] = 'rbxasset://liquidbounce/watermark-lb-logo.png'
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

local function addBlur(parent)
	local blur = Instance.new('ImageLabel')
	blur.Name = 'Blur'
	blur.Size = UDim2.new(1, 42, 1, 42)
	blur.Position = UDim2.fromOffset(-24, -15)
	blur.BackgroundTransparency = 1
	blur.Image = getcustomasset('newvape/assets/liquidbounce/blur.png')
	blur.ScaleType = Enum.ScaleType.Slice
	blur.SliceCenter = Rect.new(44, 38, 804, 595)
	blur.Parent = parent

	return blur
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

local function checkKeybinds(compare, target, key)
	if table.find(target, key) then
		for _, v in target do
			if not table.find(compare, v) then
				return false
			end
		end
		return true
	end

	return false
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
			downloader.FontFace = Font.fromEnum(Enum.Font.Arial)
			downloader.Parent = mainapi.gui
			mainapi.Downloader = downloader
		end
		downloader.Text = 'Downloading '..text
	end
end

local function createTween(time, dir)
	return TweenInfo.new(time, Enum.EasingStyle.Cubic, Enum.EasingDirection[dir or 'InOut'])
end

local function downloadFile(path, func)
	if not isfile(path) then
		createDownloader(path)
		local suc, res = pcall(function()
			local remotePath = select(1, path:gsub('newvape/', ''))
			remotePath = remotePath:gsub('^assets/liquidbounce/', 'guis/liquidbounce/assets/')
			return game:HttpGet('https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/main/src/'..remotePath, true)
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

local function removeTags(str)
	str = tostring(str or ''):gsub('<br%s*/>', '\n')
	return str:gsub('<[^<>]->', '')
end

local function ensureProfileFolder()
	pcall(function()
		if makefolder and isfolder and not isfolder('newvape/profiles') then
			makefolder('newvape/profiles')
		end
	end)
end

local function writeJson(path, value)
	ensureProfileFolder()
	return pcall(writefile, path, httpService:JSONEncode(value))
end

local function loadJson(path)
	local suc, res = pcall(function()
		return httpService:JSONDecode(readfile(path))
	end)
	return suc and type(res) == 'table' and res or nil
end

local function makeDraggable(obj, window)
	obj.InputBegan:Connect(function(inputObj)
		if window and not window.Visible or mainapi.Dragging then return end
		if
			(inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch)
			and (inputObj.Position.Y - obj.AbsolutePosition.Y < 40 or window)
		then
			mainapi.Dragging = true
			local dragPosition = Vector2.new(obj.AbsolutePosition.X - inputObj.Position.X, obj.AbsolutePosition.Y - inputObj.Position.Y + guiService:GetGuiInset().Y) / scale.Scale
			local changed = inputService.InputChanged:Connect(function(input)
				if input.UserInputType == (inputObj.UserInputType == Enum.UserInputType.MouseButton1 and Enum.UserInputType.MouseMovement or Enum.UserInputType.Touch) then
					local position = input.Position
					if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
						dragPosition = (dragPosition // 3) * 3
						position = (position // 3) * 3
					end
					obj.Position = UDim2.fromOffset((position.X / scale.Scale) + dragPosition.X, (position.Y / scale.Scale) + dragPosition.Y)
				end
			end)

			local ended
			ended = inputObj.Changed:Connect(function()
				if inputObj.UserInputState == Enum.UserInputState.End then
					mainapi.Dragging = nil
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

local function writeFont()
	if not assetfunction then return 'rbxasset://fonts/inter.json' end
	writefile('newvape/assets/liquidbounce/lbfont.json', httpService:JSONEncode({
		name = 'Inter',
		faces = {
			{style = 'normal', assetId = getcustomasset('newvape/assets/liquidbounce/Inter-Light.ttf'), name = 'Light', weight = 300},
			{style = 'normal', assetId = getcustomasset('newvape/assets/liquidbounce/Inter-Regular.ttf'), name = 'Regular', weight = 400},
			{style = 'normal', assetId = getcustomasset('newvape/assets/liquidbounce/Inter-Medium.ttf'), name = 'Medium', weight = 500}
		}
	}))
	return getcustomasset('newvape/assets/liquidbounce/lbfont.json')
end

if inputService.TouchEnabled then
	writefile('newvape/profiles/gui.txt', 'new')
	return
end

do
	local lbfont = writeFont()
	uipallet.Font = Font.new(lbfont, Enum.FontWeight.Regular)
	uipallet.FontSemiBold = Font.new(lbfont, Enum.FontWeight.Medium)
	uipallet.FontLight = Font.new(lbfont, Enum.FontWeight.Light)

	local res = isfile('newvape/profiles/color.txt') and loadJson('newvape/profiles/color.txt')
	if res then
		uipallet.Font = res.Font and Font.new(
			res.Font:find('rbxasset') and res.Font or string.format('rbxasset://fonts/families/%s.json', res.Font)
		) or uipallet.Font
		uipallet.FontSemiBold = Font.new(uipallet.Font.Family, Enum.FontWeight.SemiBold)
		uipallet.FontLight = Font.new(uipallet.Font.Family, Enum.FontWeight.Light)
	end
	uipallet.Main = liquidAccent
	uipallet.Text = Color3.new(1, 1, 1)

	fontsize.Font = uipallet.Font
end

do
	function color.Dark(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(v - num, 0, 1))
	end

	function color.Light(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, s, math.clamp(v + num, 0, 1))
	end

	function color.Saturate(col, num)
		local h, s, v = col:ToHSV()
		return Color3.fromHSV(h, math.clamp(s - (s * num), 0, 1), math.clamp(v - 0.3, 0, 1))
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

	function mainapi:TextColor(h, s, v)
		if v >= 0.7 and (s < 0.6 or h > 0.04 and h < 0.56) then
			return Color3.new(0.19, 0.19, 0.19)
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
					tab[obj]:Destroy()
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
	Divider = function(optionsettings, children)
		local text = type(optionsettings) == 'table' and (optionsettings.Name or optionsettings.Text) or optionsettings
		local holder = Instance.new('Frame')
		holder.Name = 'Divider'
		holder.Size = UDim2.new(1, 0, 0, text and 25 or 1)
		holder.BackgroundTransparency = 1
		holder.Parent = children
		local line = Instance.new('Frame')
		line.Name = 'Line'
		line.Size = UDim2.new(1, -18, 0, 1)
		line.Position = UDim2.new(0, 9, 1, -1)
		line.BackgroundColor3 = Color3.fromRGB(28, 33, 43)
		line.BorderSizePixel = 0
		line.Parent = holder
		if text then
			local label = Instance.new('TextLabel')
			label.Name = 'Title'
			label.Size = UDim2.new(1, -20, 0, 22)
			label.Position = UDim2.fromOffset(10, 0)
			label.BackgroundTransparency = 1
			label.Text = tostring(text)
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextColor3 = Color3.fromRGB(190, 194, 202)
			label.TextSize = 12
			label.FontFace = uipallet.FontSemiBold
			label.Parent = holder
		end
		return holder
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
					return func(settings, v.SettingsChildren or v.Children, v)
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

local categoryAliases = {}
local categoryGlyphs = {
	Combat = '⚔',
	Blatant = '➤',
	Movement = '➤',
	Render = '◉',
	Utility = '●',
	Player = '●',
	World = '◆',
	Inventory = '●',
	Misc = '●',
	Minigames = '⌁',
	Fun = '⌁',
	Client = '⬟',
	Legit = '◇'
}
local categoryIcons = {
	Blatant = 'newvape/assets/liquidbounce/movement.png',
	Combat = 'newvape/assets/liquidbounce/combat.png',
	Legit = 'newvape/assets/liquidbounce/player.png',
	Minigames = 'newvape/assets/liquidbounce/fun.png',
	Render = 'newvape/assets/liquidbounce/render.png',
	Utility = 'newvape/assets/liquidbounce/exploit.png',
	World = 'newvape/assets/liquidbounce/world.png'
}
local categoryCount = 0
local overlayCount = 0
local legitHudYOffset = 120
local hiddenLegitPreviews = {
	FPS = true,
	Keystrokes = true,
	Speedmeter = true
}

local function setCategoryNavColor(category, colorValue)
	if category.NavLabel then category.NavLabel.TextColor3 = colorValue end
	if category.NavIcon then
		if category.NavIcon:IsA('ImageLabel') then
			category.NavIcon.ImageColor3 = colorValue
		else
			category.NavIcon.TextColor3 = colorValue
		end
	end
end

function mainapi:CreateCategory(categorysettings)
	categoryCount += 1
	local width = categorysettings.WindowSize or 202
	local displayName = categorysettings.DisplayName or categoryAliases[categorysettings.Name] or categorysettings.Name
	local moduleTable = categorysettings.Modules or (categorysettings.Legit and self.Legit.Modules) or self.Modules
	local categoryapi = {
		Type = 'Category',
		Expanded = categorysettings.Expanded ~= false,
		Options = {},
		Modules = categorysettings.Legit and moduleTable or nil,
		Name = categorysettings.Name,
		DisplayName = displayName,
		Canonical = true
	}

	local column = (categoryCount - 1) % 8
	local row = math.floor((categoryCount - 1) / 8)
	local window = Instance.new('CanvasGroup')
	window.Name = categorysettings.Name..'Category'
	window.Size = UDim2.fromOffset(width, 32)
	window.Position = UDim2.fromOffset(210 + (column * 210), 166 + (row * 430))
	window.BackgroundColor3 = uipallet.Panel
	window.BackgroundTransparency = 0.03
	window.BorderSizePixel = 0
	window.ClipsDescendants = true
	window.Visible = categorysettings.Visible ~= false
	window.Parent = clickgui
	addCorner(window, UDim.new(0, 4))
	makeDraggable(window)

	local titlebar = Instance.new('Frame')
	titlebar.Name = 'TitleBar'
	titlebar.Size = UDim2.new(1, 0, 0, 32)
	titlebar.BackgroundColor3 = Color3.fromRGB(2, 5, 10)
	titlebar.BackgroundTransparency = 0.02
	titlebar.BorderSizePixel = 0
	titlebar.Parent = window
	local iconPath = categorysettings.Icon or categoryIcons[displayName] or categoryIcons[categorysettings.Name]
	local icon
	if iconPath then
		icon = Instance.new('ImageLabel')
		icon.Size = UDim2.fromOffset(16, 16)
		icon.Position = UDim2.fromOffset(10, 8)
		icon.Image = iconPath:find('^rbxasset') and iconPath or getcustomasset(iconPath)
		icon.ImageColor3 = Color3.fromRGB(239, 241, 246)
		icon.ScaleType = Enum.ScaleType.Fit
	else
		icon = Instance.new('TextLabel')
		icon.Size = UDim2.fromOffset(27, 30)
		icon.Position = UDim2.fromOffset(6, 0)
		icon.Text = categorysettings.Glyph or categoryGlyphs[displayName] or categoryGlyphs[categorysettings.Name] or '●'
		icon.TextColor3 = Color3.fromRGB(239, 241, 246)
		icon.TextSize = 13
		icon.FontFace = uipallet.FontSemiBold
	end
	icon.Name = 'Icon'
	icon.BackgroundTransparency = 1
	icon.Parent = titlebar
	local title = Instance.new('TextLabel')
	title.Name = 'Title'
	title.Size = UDim2.new(1, -61, 1, 0)
	title.Position = UDim2.fromOffset(31, 0)
	title.BackgroundTransparency = 1
	title.Text = displayName
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = Color3.fromRGB(235, 237, 242)
	title.TextSize = 13
	title.FontFace = uipallet.FontSemiBold
	title.Parent = titlebar
	local collapse = Instance.new('TextButton')
	collapse.Name = 'Collapse'
	collapse.Size = UDim2.fromOffset(30, 31)
	collapse.Position = UDim2.new(1, -32, 0, 0)
	collapse.BackgroundTransparency = 1
	collapse.AutoButtonColor = false
	collapse.Text = categoryapi.Expanded and '−' or '+'
	collapse.TextColor3 = Color3.fromRGB(226, 229, 236)
	collapse.TextSize = 18
	collapse.FontFace = uipallet.FontSemiBold
	collapse.Parent = titlebar
	local divider = Instance.new('Frame')
	divider.Name = 'Accent'
	divider.Size = UDim2.new(1, 0, 0, 1)
	divider.Position = UDim2.fromOffset(0, 31)
	divider.BackgroundColor3 = uipallet.Main
	divider.BorderSizePixel = 0
	divider.Parent = titlebar

	local children = Instance.new('ScrollingFrame')
	children.Name = 'Children'
	children.Size = UDim2.new(1, 0, 1, -32)
	children.Position = UDim2.fromOffset(0, 32)
	children.BackgroundColor3 = uipallet.Panel
	children.BackgroundTransparency = 0.03
	children.BorderSizePixel = 0
	children.ScrollBarThickness = 2
	children.ScrollBarImageColor3 = uipallet.Main
	children.ScrollBarImageTransparency = 0.15
	children.CanvasSize = UDim2.new()
	children.Parent = window
	local categorylist = Instance.new('UIListLayout')
	categorylist.SortOrder = Enum.SortOrder.LayoutOrder
	categorylist.HorizontalAlignment = Enum.HorizontalAlignment.Center
	categorylist.Parent = children

	local resizingCategory = false
	local function resizeCategory(instant)
		if resizingCategory then return end
		resizingCategory = true
		local contentHeight = categorylist.AbsoluteContentSize.Y / scale.Scale
		children.CanvasSize = UDim2.fromOffset(0, contentHeight)
		local height = categoryapi.Expanded and math.min(32 + contentHeight, categorysettings.MaxHeight or 470) or 32
		if instant then
			window.Size = UDim2.fromOffset(width, height)
		else
			tween:Tween(window, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(width, height)
			})
		end
		resizingCategory = false
	end

	function categoryapi:CreateModule(modulesettings)
		mainapi:Remove(modulesettings.Name)
		local moduleapi = {
			Enabled = false,
			Expanded = false,
			Options = {},
			Bind = {},
			Index = getTableSize(moduleTable) + 1,
			ExtraText = modulesettings.ExtraText,
			Name = modulesettings.Name,
			Category = categorysettings.Name,
			CategoryObject = categoryapi
		}
		local hovered = false
		local modulebutton = Instance.new('TextButton')
		modulebutton.Name = modulesettings.Name
		modulebutton.Size = UDim2.new(1, 0, 0, 28)
		modulebutton.BackgroundColor3 = uipallet.Panel
		modulebutton.BackgroundTransparency = 0.03
		modulebutton.BorderSizePixel = 0
		modulebutton.AutoButtonColor = false
		modulebutton.Text = '    '..modulesettings.Name
		modulebutton.TextXAlignment = Enum.TextXAlignment.Left
		modulebutton.TextColor3 = Color3.fromRGB(197, 201, 209)
		modulebutton.TextSize = 12
		modulebutton.FontFace = uipallet.Font
		modulebutton.Parent = children
		local activebar = Instance.new('Frame')
		activebar.Name = 'ActiveAccent'
		activebar.Size = UDim2.new(0, 2, 1, 0)
		activebar.BackgroundColor3 = uipallet.Main
		activebar.BackgroundTransparency = 1
		activebar.BorderSizePixel = 0
		activebar.Parent = modulebutton
		local expandicon = Instance.new('ImageLabel')
		expandicon.Name = 'Expand'
		expandicon.Size = UDim2.fromOffset(10, 6)
		expandicon.Position = UDim2.new(1, -18, 0.5, -3)
		expandicon.BackgroundTransparency = 1
		expandicon.Image = getcustomasset('newvape/assets/liquidbounce/settings-expand.png')
		expandicon.ImageColor3 = Color3.fromRGB(119, 125, 136)
		expandicon.Rotation = -90
		expandicon.Parent = modulebutton
		local modulechildren = Instance.new('Frame')
		modulechildren.Name = modulesettings.Name..'Children'
		modulechildren.Size = UDim2.new(1, 0, 0, 0)
		modulechildren.BackgroundColor3 = Color3.fromRGB(1, 4, 9)
		modulechildren.BackgroundTransparency = 0.01
		modulechildren.BorderSizePixel = 0
		modulechildren.ClipsDescendants = true
		modulechildren.Visible = false
		modulechildren.Parent = children
		local settingsaccent = Instance.new('Frame')
		settingsaccent.Name = 'Accent'
		settingsaccent.Size = UDim2.fromOffset(2, 0)
		settingsaccent.Position = UDim2.fromOffset(0, 28)
		settingsaccent.BackgroundColor3 = uipallet.Main
		settingsaccent.BorderSizePixel = 0
		settingsaccent.Visible = false
		settingsaccent.Parent = modulebutton
		local modulelist = Instance.new('UIListLayout')
		modulelist.SortOrder = Enum.SortOrder.LayoutOrder
		modulelist.HorizontalAlignment = Enum.HorizontalAlignment.Center
		modulelist.Parent = modulechildren
		moduleapi.Children = modulechildren
		local hudchildren
		if categorysettings.Legit and modulesettings.Size then
			hudchildren = Instance.new('Frame')
			hudchildren.Name = modulesettings.Name..'HUD'
			hudchildren.Size = modulesettings.Size
			hudchildren.Position = UDim2.fromOffset(12, legitHudYOffset)
			legitHudYOffset += math.max(modulesettings.Size.Y.Offset + 10, 52)
			hudchildren.BackgroundTransparency = 1
			hudchildren.BorderSizePixel = 0
			hudchildren.Active = true
			hudchildren.Visible = false
			hudchildren.Parent = scaledgui
			makeDraggable(hudchildren)
			moduleapi.OriginalChildren = modulechildren
			moduleapi.SettingsChildren = modulechildren
			moduleapi.HudChildren = hudchildren
			moduleapi.Children = hudchildren

			if not hiddenLegitPreviews[modulesettings.Name] then
				local previewHeight = math.max(53, modulesettings.Size.Y.Offset + 12)
				local previewholder = Instance.new('Frame')
				previewholder.Name = 'HUDPreview'
				previewholder.Size = UDim2.new(1, 0, 0, previewHeight)
				previewholder.BackgroundColor3 = Color3.fromRGB(0, 2, 6)
				previewholder.BorderSizePixel = 0
				previewholder.ClipsDescendants = true
				previewholder.LayoutOrder = 100000
				previewholder.Parent = modulechildren
				addCorner(previewholder, UDim.new(0, 3))
				local previewcanvas = Instance.new('Frame')
				previewcanvas.Name = 'PreviewCanvas'
				previewcanvas.Size = modulesettings.Size
				previewcanvas.AnchorPoint = Vector2.new(0.5, 0.5)
				previewcanvas.Position = UDim2.fromScale(0.5, 0.5)
				previewcanvas.BackgroundTransparency = 1
				previewcanvas.Parent = previewholder
				local previewQueued = false
				local function refreshPreview()
					if previewQueued then return end
					previewQueued = true
					task.defer(function()
						if not previewcanvas.Parent then
							previewQueued = false
							return
						end
						previewcanvas:ClearAllChildren()
						for _, child in hudchildren:GetChildren() do
							local success, clone = pcall(function() return child:Clone() end)
							if success and clone then clone.Parent = previewcanvas end
						end
						previewQueued = false
					end)
				end
				local function watchPreviewObject(object)
					if not object:IsA('GuiObject') then return end
					mainapi:Clean(object.Changed:Connect(function(property)
						if property ~= 'AbsolutePosition' and property ~= 'AbsoluteSize' and property ~= 'AbsoluteRotation' then
							refreshPreview()
						end
					end))
				end
				mainapi:Clean(hudchildren.DescendantAdded:Connect(function(object)
					watchPreviewObject(object)
					refreshPreview()
				end))
				mainapi:Clean(hudchildren.DescendantRemoving:Connect(refreshPreview))
				for _, object in hudchildren:GetDescendants() do watchPreviewObject(object) end
				refreshPreview()
			end
		end
		modulesettings.Function = modulesettings.Function or function() end
		addMaid(moduleapi)
		local moduleLayoutQueued = false
		local function updateModuleLayout()
			if moduleLayoutQueued then return end
			moduleLayoutQueued = true
			task.defer(function()
				if not modulechildren.Parent then
					moduleLayoutQueued = false
					return
				end
				if mainapi.ThreadFix then setthreadidentity(8) end
				local targetHeight = math.max(0, modulelist.AbsoluteContentSize.Y / scale.Scale)
				if math.abs(modulechildren.Size.Y.Offset - targetHeight) > 0.5 then
					modulechildren.Size = UDim2.new(1, 0, 0, targetHeight)
					settingsaccent.Size = UDim2.fromOffset(2, targetHeight)
				end
				moduleLayoutQueued = false
			end)
		end
		function moduleapi:UpdateLayout()
			updateModuleLayout()
		end
		modulelist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateModuleLayout)

		function moduleapi:Toggle(multiple)
			if mainapi.ThreadFix then setthreadidentity(8) end
			self.Enabled = not self.Enabled
			if hudchildren then hudchildren.Visible = self.Enabled end
			tween:Tween(modulebutton, uipallet.Tween, {
				TextColor3 = self.Enabled and uipallet.Main or (hovered and Color3.new(1, 1, 1) or Color3.fromRGB(197, 201, 209))
			}, tween.tweenstwo)
			tween:Tween(activebar, uipallet.Tween, {
				BackgroundTransparency = self.Enabled and 0 or 1
			})
			if not self.Enabled then
				for _, connection in self.Connections do
					pcall(function() connection:Disconnect() end)
				end
				table.clear(self.Connections)
			end
			if not multiple then
				mainapi:UpdateTextGUI()
			end
			mainapi:UpdateBinds()
			task.spawn(modulesettings.Function, self.Enabled)
		end

		function moduleapi:SetExpanded(value)
			if value == nil then
				self.Expanded = not self.Expanded
			else
				self.Expanded = value
			end
			modulechildren.Visible = self.Expanded
			settingsaccent.Visible = self.Expanded
			expandicon.Rotation = self.Expanded and 0 or -90
			expandicon.ImageColor3 = self.Expanded and uipallet.Main or Color3.fromRGB(119, 125, 136)
			updateModuleLayout()
		end

		for name, component in components do
			moduleapi['Create'..name] = function(_, optionsettings)
				return component(optionsettings, modulechildren, moduleapi)
			end
		end
		if moduleapi.CreateBind then moduleapi:CreateBind() end
		modulebutton.MouseEnter:Connect(function()
			hovered = true
			modulebutton.BackgroundColor3 = uipallet.PanelLight
			if not moduleapi.Enabled then modulebutton.TextColor3 = Color3.new(1, 1, 1) end
		end)
		modulebutton.MouseLeave:Connect(function()
			hovered = false
			modulebutton.BackgroundColor3 = uipallet.Panel
			if not moduleapi.Enabled then modulebutton.TextColor3 = Color3.fromRGB(197, 201, 209) end
		end)
		modulebutton.MouseButton1Click:Connect(function()
			if inputService:IsKeyDown(Enum.KeyCode.LeftShift) then
				mainapi.Binding = moduleapi
				modulebutton.Text = '    Press a key'
				task.delay(1.2, function()
					if modulebutton.Parent then modulebutton.Text = '    '..modulesettings.Name end
				end)
			else
				moduleapi:Toggle()
			end
		end)
		modulebutton.MouseButton2Click:Connect(function()
			moduleapi:SetExpanded()
		end)
		updateModuleLayout()

		moduleapi.Object = modulebutton
		moduleTable[modulesettings.Name] = moduleapi
		local names = {}
		for name, object in moduleTable do
			if object.Category == categorysettings.Name then table.insert(names, name) end
		end
		table.sort(names)
		for index, name in names do
			local object = moduleTable[name]
			local optionChildren = object.OriginalChildren or object.Children
			object.Index = index
			object.Object.LayoutOrder = index * 2
			optionChildren.LayoutOrder = (index * 2) + 1
		end
		if searchbox and searchbox.Text ~= '' then searchbox.Text = searchbox.Text end
		return moduleapi
	end

	function categoryapi:Expand(value, instant)
		if value == nil then
			self.Expanded = not self.Expanded
		else
			self.Expanded = value
		end
		collapse.Text = self.Expanded and '−' or '+'
		resizeCategory(instant)
	end

	for name, component in components do
		categoryapi['Create'..name] = function(_, optionsettings)
			return component(optionsettings, children, categoryapi)
		end
	end
	collapse.MouseButton1Click:Connect(function() categoryapi:Expand() end)
	titlebar.InputBegan:Connect(function(inputObj)
		if inputObj.UserInputType == Enum.UserInputType.MouseButton2 then categoryapi:Expand() end
	end)
	categorylist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		if mainapi.ThreadFix then setthreadidentity(8) end
		resizeCategory(true)
	end)

	categoryapi.Object = window
	categoryapi.Children = children
	self.Categories[categorysettings.Name] = categoryapi
	if categoryholder and categorysettings.ShowInSidebar ~= false then
		local nav = Instance.new('TextButton')
		nav.Name = categorysettings.Name
		nav.Size = UDim2.new(1, 0, 0, 30)
		nav.BackgroundTransparency = 1
		nav.AutoButtonColor = false
		nav.Text = ''
		nav.Parent = categoryholder
		local navicon
		if iconPath then
			navicon = Instance.new('ImageLabel')
			navicon.Size = UDim2.fromOffset(14, 14)
			navicon.Position = UDim2.fromOffset(17, 8)
			navicon.Image = iconPath:find('^rbxasset') and iconPath or getcustomasset(iconPath)
			navicon.ImageColor3 = Color3.fromRGB(143, 148, 158)
			navicon.ScaleType = Enum.ScaleType.Fit
		else
			navicon = Instance.new('TextLabel')
			navicon.Size = UDim2.fromOffset(16, 28)
			navicon.Position = UDim2.fromOffset(16, 1)
			navicon.Text = categorysettings.Glyph or categoryGlyphs[displayName] or categoryGlyphs[categorysettings.Name] or '●'
			navicon.TextColor3 = Color3.fromRGB(143, 148, 158)
			navicon.TextSize = 11
			navicon.FontFace = uipallet.FontSemiBold
		end
		navicon.Name = 'Icon'
		navicon.BackgroundTransparency = 1
		navicon.Parent = nav
		local navlabel = Instance.new('TextLabel')
		navlabel.Name = 'Label'
		navlabel.Size = UDim2.new(1, -45, 1, 0)
		navlabel.Position = UDim2.fromOffset(40, 0)
		navlabel.BackgroundTransparency = 1
		navlabel.Text = displayName
		navlabel.TextXAlignment = Enum.TextXAlignment.Left
		navlabel.TextColor3 = Color3.fromRGB(143, 148, 158)
		navlabel.TextSize = 13
		navlabel.FontFace = uipallet.Font
		navlabel.Parent = nav
		local navaccent = Instance.new('Frame')
		navaccent.Name = 'Accent'
		navaccent.Size = UDim2.new(0, 2, 0, 18)
		navaccent.Position = UDim2.fromOffset(8, 6)
		navaccent.BackgroundColor3 = uipallet.Main
		navaccent.BackgroundTransparency = 1
		navaccent.BorderSizePixel = 0
		navaccent.Parent = nav
		categoryapi.NavButton = nav
		categoryapi.NavIcon = navicon
		categoryapi.NavLabel = navlabel
		nav.MouseEnter:Connect(function() setCategoryNavColor(categoryapi, Color3.new(1, 1, 1)) end)
		nav.MouseLeave:Connect(function()
			setCategoryNavColor(categoryapi, lastSelected == categoryapi and uipallet.Main or Color3.fromRGB(143, 148, 158))
		end)
		nav.MouseButton1Click:Connect(function()
			lastSelected = categoryapi
			window.Visible = true
			categoryapi:Expand(true, true)
			window.Position = UDim2.fromOffset(math.max(210, (gui.AbsoluteSize.X / scale.Scale - width) / 2), 120)
			for _, other in mainapi.Categories do
				if other.NavButton then
					setCategoryNavColor(other, other == categoryapi and uipallet.Main or Color3.fromRGB(143, 148, 158))
					other.NavButton.Accent.BackgroundTransparency = other == categoryapi and 0 or 1
				end
			end
		end)
	end
	resizeCategory(true)
	return categoryapi
end

function mainapi:CreateOverlay(categorysettings)
	overlayCount += 1
	local customchildren = Instance.new(categorysettings.NoDrag and 'Frame' or 'TextButton')
	customchildren.Name = categorysettings.Name..'Overlay'
	customchildren.Size = UDim2.fromOffset(categorysettings.WindowSize or 220, categorysettings.WindowHeight or 220)
	customchildren.Position = categorysettings.WindowPosition or UDim2.fromOffset(12 + ((overlayCount - 1) * 230), 76)
	customchildren.BackgroundTransparency = 1
	customchildren.Visible = false
	customchildren.Parent = scaledgui
	if customchildren:IsA('TextButton') then
		customchildren.AutoButtonColor = false
		customchildren.Text = ''
		makeDraggable(customchildren, customchildren)
	end

	local overlay
	overlay = self.Categories.Render:CreateModule({
		Name = categorysettings.Name,
		ExtraText = categorysettings.ExtraText,
		Function = function(enabled)
			customchildren.Visible = enabled
			if categorysettings.Function then categorysettings.Function(enabled) end
		end
	})
	overlay.OriginalChildren = overlay.Children
	overlay.Children = customchildren
	overlay.Button = overlay
	overlay.Object.Name = categorysettings.Name
	return overlay
end

function mainapi:CreateNotification(title, text, duration, type)
	if self.Notifications and self.Notifications.Enabled == false then return end
	duration = duration or 3
	task.spawn(function()
		if self.ThreadFix then setthreadidentity(8) end
		local index = #notifications:GetChildren() + 1
		local card = Instance.new('Frame')
		card.Name = 'Notification'
		card.Size = UDim2.fromOffset(286, 58)
		card.Position = UDim2.new(1, 300, 1, -(24 + (index * 66)))
		card.BackgroundColor3 = Color3.fromRGB(3, 6, 12)
		card.BackgroundTransparency = 0.04
		card.BorderSizePixel = 0
		card.Parent = notifications
		addCorner(card, UDim.new(0, 4))
		local accent = Instance.new('Frame')
		accent.Name = 'Accent'
		accent.Size = UDim2.new(0, 3, 1, 0)
		accent.BackgroundColor3 = type == 'alert' and Color3.fromRGB(244, 73, 82) or type == 'warning' and Color3.fromRGB(240, 169, 60) or uipallet.Main
		accent.BorderSizePixel = 0
		accent.Parent = card
		local statusicon = Instance.new('ImageLabel')
		statusicon.Name = 'Icon'
		statusicon.Size = UDim2.fromOffset(16, 16)
		statusicon.Position = UDim2.fromOffset(13, 21)
		statusicon.BackgroundTransparency = 1
		statusicon.Image = getcustomasset('newvape/assets/liquidbounce/notification-'..(type == 'alert' and 'error' or type == 'warning' and 'info' or 'success')..'.png')
		statusicon.ImageColor3 = accent.BackgroundColor3
		statusicon.ScaleType = Enum.ScaleType.Fit
		statusicon.Parent = card
		local titlelabel = Instance.new('TextLabel')
		titlelabel.Size = UDim2.new(1, -48, 0, 20)
		titlelabel.Position = UDim2.fromOffset(38, 7)
		titlelabel.BackgroundTransparency = 1
		titlelabel.Text = title or 'LiquidBounce'
		titlelabel.TextXAlignment = Enum.TextXAlignment.Left
		titlelabel.TextColor3 = Color3.fromRGB(239, 241, 246)
		titlelabel.TextSize = 13
		titlelabel.FontFace = uipallet.FontSemiBold
		titlelabel.Parent = card
		local body = titlelabel:Clone()
		body.Size = UDim2.new(1, -48, 0, 18)
		body.Position = UDim2.fromOffset(38, 29)
		body.Text = removeTags(text)
		body.TextColor3 = Color3.fromRGB(151, 156, 167)
		body.TextSize = 12
		body.TextTruncate = Enum.TextTruncate.AtEnd
		body.FontFace = uipallet.Font
		body.Parent = card
		local progress = Instance.new('Frame')
		progress.Name = 'Accent'
		progress.Size = UDim2.new(1, -3, 0, 1)
		progress.Position = UDim2.new(0, 3, 1, -1)
		progress.BackgroundColor3 = accent.BackgroundColor3
		progress.BorderSizePixel = 0
		progress.Parent = card
		tween:Tween(card, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -302, 1, -(24 + (index * 66)))
		})
		tween:Tween(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.fromOffset(0, 1)
		})
		task.wait(duration)
		tween:Tween(card, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 300, 1, card.Position.Y.Offset)
		})
		task.wait(0.22)
		card:Destroy()
	end)
end

function mainapi:Load(skipgui, profile)
	self.Loading = true
	local guiPath = 'newvape/profiles/'..game.GameId..'.gui.txt'
	local guidata = isfile(guiPath) and loadJson(guiPath) or {}
	if type(guidata) ~= 'table' then guidata = {} end
	self.Keybind = type(guidata.Keybind) == 'table' and guidata.Keybind or self.Keybind
	self.Profile = profile or guidata.Profile or self.Profile or 'default'
	self.Profiles = type(guidata.Profiles) == 'table' and guidata.Profiles or {{Name = 'default', Bind = {}}}

	for name, saved in (guidata.Categories or {}) do
		local object = self.Categories[name]
		if object and object.Canonical then
			if saved.Position then object.Object.Position = UDim2.fromOffset(saved.Position.X or 0, saved.Position.Y or 0) end
			if saved.Expanded ~= nil and object.Expand then object:Expand(saved.Expanded, true) end
			if saved.Options then self:LoadOptions(object, saved.Options) end
		end
	end

	local profilePath = 'newvape/profiles/'..self.Profile..self.Place..'.txt'
	local savedata = isfile(profilePath) and loadJson(profilePath) or nil
	if type(savedata) == 'table' then
		for name, saved in (savedata.Categories or {}) do
			local object = self.Categories[name]
			if object and object.Canonical then
				if saved.Position then object.Object.Position = UDim2.fromOffset(saved.Position.X or 0, saved.Position.Y or 0) end
				if saved.Expanded ~= nil and object.Expand then object:Expand(saved.Expanded, true) end
			end
		end
		for name, saved in (savedata.Modules or {}) do
			local object = self.Modules[name]
			if object then
				if saved.Options then self:LoadOptions(object, saved.Options) end
				if object.SetBind then object:SetBind(type(saved.Bind) == 'table' and saved.Bind or {}) end
				if saved.Enabled ~= nil and saved.Enabled ~= object.Enabled then object:Toggle(true) end
			end
		end
		for name, saved in (savedata.Legit or {}) do
			local object = self.Legit and self.Legit.Modules and self.Legit.Modules[name]
			if object then
				if saved.Position and object.HudChildren then
					object.HudChildren.Position = UDim2.fromOffset(saved.Position.X or 0, saved.Position.Y or 0)
				end
				if saved.Options then self:LoadOptions(object, saved.Options) end
				if object.SetBind then object:SetBind(type(saved.Bind) == 'table' and saved.Bind or {}) end
				if saved.Enabled ~= nil and saved.Enabled ~= object.Enabled then object:Toggle(true) end
			end
		end
	else
		savedata = {Modules = {}}
	end

	self.Loaded = true
	if self.GUIBind and self.GUIBind.SetBind then self.GUIBind:SetBind(self.Keybind) end
	if self.Categories.Profiles and self.Categories.Profiles.ChangeValue then self.Categories.Profiles:ChangeValue() end
	self.Loading = nil
	if not isfile(guiPath) or not isfile(profilePath) then self:Save() end
	if self.Downloader then
		self.Downloader:Destroy()
		self.Downloader = nil
	end
	self:UpdateTextGUI(true)
	self:UpdateBinds(true)
end

function mainapi:LoadOptions(object, savedoptions)
	for name, saved in savedoptions do
		local option = object.Options and object.Options[name]
		if option and option.Load then option:Load(saved) end
	end
end

function mainapi:Remove(obj)
	local tab = (self.Modules[obj] and self.Modules or self.Legit.Modules[obj] and self.Legit.Modules or self.Categories)
	if tab and tab[obj] then
		local newobj = tab[obj]
		if self.ThreadFix then
			setthreadidentity(8)
		end

		local destroyed = {}
		for _, v in {'Object', 'OriginalChildren', 'Children', 'Toggle', 'Button'} do
			local childobj = typeof(newobj[v]) == 'table' and newobj[v].Object or newobj[v]
			if typeof(childobj) == 'Instance' and not destroyed[childobj] then
				destroyed[childobj] = true
				childobj:ClearAllChildren()
				childobj:Destroy()
			end
		end

		loopClean(newobj)
		tab[obj] = nil
	end
end

function mainapi:Save(newprofile)
	if self.Loaded ~= true then return end
	local guidata = {
		Categories = {},
		Profile = newprofile or self.Profile,
		Profiles = self.Profiles,
		Keybind = self.Keybind
	}
	local savedata = {Categories = {}, Modules = {}, Legit = {}}
	for name, object in self.Categories do
		if object.Canonical and object.Name == name then
			local categorydata = {
				Expanded = object.Expanded,
				Position = {X = object.Object.Position.X.Offset, Y = object.Object.Position.Y.Offset},
				Options = self:SaveOptions(object, true)
			}
			guidata.Categories[name] = categorydata
			savedata.Categories[name] = categorydata
		end
	end
	for name, object in self.Modules do
		savedata.Modules[name] = {
			Enabled = object.Enabled,
			Bind = object.Bind,
			Options = self:SaveOptions(object, true)
		}
	end
	if self.Legit and self.Legit.Modules then
		for name, object in self.Legit.Modules do
			savedata.Legit[name] = {
				Enabled = object.Enabled,
				Bind = object.Bind,
				Position = object.HudChildren and {
					X = object.HudChildren.Position.X.Offset,
					Y = object.HudChildren.Position.Y.Offset
				} or nil,
				Options = self:SaveOptions(object, true)
			}
		end
	end
	writeJson('newvape/profiles/'..game.GameId..'.gui.txt', guidata)
	writeJson('newvape/profiles/'..self.Profile..self.Place..'.txt', savedata)
end

function mainapi:SaveOptions(object, savedoptions)
	if not savedoptions or not object.Options then return {} end
	local result = {}
	for _, option in object.Options do
		if option.Save then option:Save(result) end
	end
	return result
end

function mainapi:Uninject()
	self:Save()
	self.Loaded = nil
	for _, object in self.Modules do
		if object.Enabled then object:Toggle(true) end
	end
	if self.Legit and self.Legit.Modules then
		for _, object in self.Legit.Modules do
			if object.Enabled then object:Toggle(true) end
		end
	end
	for _, connection in self.Connections do
		pcall(function() connection:Disconnect() end)
	end
	if self.ThreadFix then
		setthreadidentity(8)
		clickgui.Visible = false
		self:BlurCheck()
	end
	gui:ClearAllChildren()
	gui:Destroy()
	table.clear(self.Connections)
	table.clear(self.Libraries)
	shared.vape = nil
	shared.vapereload = nil
end

function mainapi:Reinject(guiTheme)
	self:Save()
	if guiTheme then
		pcall(writefile, 'newvape/profiles/gui.txt', guiTheme:lower())
	end
	shared.vapereload = true
	if shared.VapeDeveloper then
		loadstring(readfile('newvape/loader.lua'), 'loader')()
	else
		loadstring(game:HttpGet('https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/main/src/loader.lua', true), 'loader')()
	end
end

function mainapi:UpdateGUI(_, _, _, default)
	if self.Loaded == nil then return end
	local hue, sat, val = liquidHue, liquidSat, liquidValue
	self.GUIColor.Hue = hue
	self.GUIColor.Sat = sat
	self.GUIColor.Value = val
	local oldAccent = uipallet.Main
	local newAccent = liquidAccent
	uipallet.Main = newAccent
	for _, object in gui:GetDescendants() do
		if object:IsA('GuiObject') then
			if object.Name == 'Accent' or object.Name == 'ActiveAccent' or object.BackgroundColor3 == oldAccent then
				object.BackgroundColor3 = newAccent
			end
			if (object:IsA('TextLabel') or object:IsA('TextButton') or object:IsA('TextBox')) and object.TextColor3 == oldAccent then
				object.TextColor3 = newAccent
			end
			if (object:IsA('ImageLabel') or object:IsA('ImageButton')) and object.ImageColor3 == oldAccent then
				object.ImageColor3 = newAccent
			end
			if object:IsA('ScrollingFrame') and object.ScrollBarImageColor3 == oldAccent then
				object.ScrollBarImageColor3 = newAccent
			end
		elseif object:IsA('UIStroke') and object.Name == 'Accent' then
			object.Color = newAccent
		end
	end
	for _, module in self.Modules do
		if module.Enabled and module.Object then module.Object.TextColor3 = newAccent end
		for _, option in module.Options do
			if type(option.Color) == 'function' then option:Color(hue, sat, val, false) end
		end
	end
	if self.Legit and self.Legit.Modules then
		for _, module in self.Legit.Modules do
			if module.Enabled and module.Object then module.Object.TextColor3 = newAccent end
			for _, option in module.Options do
				if type(option.Color) == 'function' then option:Color(hue, sat, val, false) end
			end
		end
	end
	if textguilogo then textguilogo.ImageColor3 = Color3.new(1, 1, 1) end
end

function mainapi:UpdateTextGUI(afterload)
	if not afterload and self.Loaded ~= true then return end
	if not textgui or not textguiholder then return end
	textguiholder.Visible = textgui.Enabled
	if textguilogo then
		textguilogo.Visible = textgui.Enabled
			and (not textgui.WatermarkOption or textgui.WatermarkOption.Enabled)
			and not clickgui.Visible
	end
	if not textgui.Enabled then return end
	for _, child in textguiholder:GetChildren() do
		if not child:IsA('UIListLayout') then child:Destroy() end
	end
	local active = {}
	for name, module in self.Modules do
		if module.Enabled and module ~= textgui and module ~= bindsmodule then table.insert(active, {Name = name, Module = module}) end
	end
	if self.Legit and self.Legit.Modules then
		for name, module in self.Legit.Modules do
			if module.Enabled then table.insert(active, {Name = name, Module = module}) end
		end
	end
	if textgui.SortOption and textgui.SortOption.Value == 'Alphabetical' then
		table.sort(active, function(a, b) return a.Name:lower() < b.Name:lower() end)
	else
		table.sort(active, function(a, b)
			return getfontsize(a.Name, 14, uipallet.Font).X > getfontsize(b.Name, 14, uipallet.Font).X
		end)
	end
	for index, data in active do
		local name = textgui.LowercaseOption and textgui.LowercaseOption.Enabled and data.Name:lower() or data.Name
		local extra
		if data.Module.ExtraText then
			local success, result = pcall(data.Module.ExtraText)
			if success and result ~= nil and tostring(result) ~= '' then extra = tostring(result) end
		end
		local displayText = name..(extra and ' '..extra or '')
		local label = Instance.new('TextLabel')
		label.Name = data.Name
		label.Size = UDim2.fromOffset(math.ceil(getfontsize(displayText, 14, uipallet.FontSemiBold).X) + 10, 22)
		label.BackgroundColor3 = Color3.fromRGB(2, 5, 10)
		label.BackgroundTransparency = textgui.BackgroundOption and textgui.BackgroundOption.Enabled and 0.18 or 1
		label.BorderSizePixel = 0
		label.ClipsDescendants = true
		label.Text = displayText
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextColor3 = Color3.fromRGB(235, 238, 244)
		label.TextSize = 14
		label.FontFace = uipallet.FontSemiBold
		label.LayoutOrder = index
		label.Parent = textguiholder
		addCorner(label, UDim.new(0, 2))
		local padding = Instance.new('UIPadding')
		padding.PaddingLeft = UDim.new(0, 7)
		padding.PaddingRight = UDim.new(0, 3)
		padding.Parent = label
		local line = Instance.new('ImageLabel')
		line.Name = 'Accent'
		line.Size = UDim2.new(0, 4, 1, 0)
		line.Position = UDim2.fromOffset(-9, 0)
		line.BackgroundTransparency = 1
		line.Image = getcustomasset('newvape/assets/liquidbounce/textgui.png')
		line.ScaleType = Enum.ScaleType.Stretch
		line.ImageColor3 = Color3.new(1, 1, 1)
		line.Parent = label
	end
end

local function formatBind(bind)
	local formatted = {}
	for _, key in bind do
		key = tostring(key):gsub('(%l)(%u)', '%1 %2')
		table.insert(formatted, key)
	end
	return table.concat(formatted, ' + ')
end

function mainapi:UpdateBinds(afterload)
	if not afterload and self.Loaded ~= true then return end
	if not bindsmodule or not bindsholder then return end
	bindsholder.Visible = bindsmodule.Enabled
	if not bindsmodule.Enabled then return end
	for _, child in bindsholder:GetChildren() do
		if child.Name == 'BindRow' then child:Destroy() end
	end

	local binds = {{Name = 'Click GUI', Bind = self.Keybind, Enabled = clickgui.Visible}}
	local function addBinds(modules)
		for name, module in modules do
			if module ~= bindsmodule and type(module.Bind) == 'table' and #module.Bind > 0 then
				table.insert(binds, {Name = name, Bind = module.Bind, Enabled = module.Enabled})
			end
		end
	end
	addBinds(self.Modules)
	if self.Legit and self.Legit.Modules then addBinds(self.Legit.Modules) end
	table.sort(binds, function(a, b)
		if a.Name == 'Click GUI' then return true end
		if b.Name == 'Click GUI' then return false end
		return a.Name:lower() < b.Name:lower()
	end)

	local width = 144
	local maxKeyWidth = 0
	for _, data in binds do
		local keyText = '['..formatBind(data.Bind)..']'
		local keyWidth = math.ceil(getfontsize(keyText, 11, uipallet.Font).X)
		maxKeyWidth = math.max(maxKeyWidth, keyWidth)
		width = math.max(width, math.ceil(getfontsize(data.Name, 12, uipallet.Font).X + keyWidth + 30))
	end
	for index, data in binds do
		local row = Instance.new('Frame')
		row.Name = 'BindRow'
		row.Size = UDim2.fromOffset(width, 18)
		row.Position = UDim2.fromOffset(0, 25 + ((index - 1) * 18))
		row.BackgroundColor3 = Color3.fromRGB(4, 8, 15)
		row.BackgroundTransparency = index % 2 == 0 and 0.18 or 0.35
		row.BorderSizePixel = 0
		row.ZIndex = 7
		row.Parent = bindsholder
		local active = Instance.new('Frame')
		active.Name = 'Accent'
		active.Size = UDim2.new(0, 2, 1, 0)
		active.BackgroundColor3 = uipallet.Main
		active.BackgroundTransparency = data.Enabled and 0 or 1
		active.BorderSizePixel = 0
		active.ZIndex = 8
		active.Parent = row
		local name = Instance.new('TextLabel')
		name.Size = UDim2.new(1, -(maxKeyWidth + 24), 1, 0)
		name.Position = UDim2.fromOffset(8, 0)
		name.BackgroundTransparency = 1
		name.Text = data.Name
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextColor3 = Color3.new(1, 1, 1)
		name.TextTransparency = 0
		name.TextSize = 12
		name.FontFace = uipallet.Font
		name.ZIndex = 8
		name.Parent = row
		local key = Instance.new('TextLabel')
		key.Size = UDim2.fromOffset(maxKeyWidth, 18)
		key.Position = UDim2.new(1, -(maxKeyWidth + 8), 0, 0)
		key.BackgroundTransparency = 1
		key.Text = '['..formatBind(data.Bind)..']'
		key.TextXAlignment = Enum.TextXAlignment.Right
		key.TextColor3 = Color3.fromRGB(196, 201, 211)
		key.TextTransparency = 0
		key.TextSize = 11
		key.FontFace = uipallet.Font
		key.ZIndex = 8
		key.Parent = row
	end
	bindsholder.Size = UDim2.fromOffset(width, 30 + (#binds * 18))
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
clickgui.BackgroundTransparency = 0.46
clickgui.BackgroundColor3 = Color3.fromRGB(0, 8, 20)
clickgui.BorderSizePixel = 0
clickgui.Visible = false
clickgui.Parent = scaledgui
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
scale = Instance.new('UIScale')
scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 1)
scale.Parent = scaledgui
mainapi.guiscale = scale
scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)

mainapi:Clean(gui:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
	if mainapi.Scale.Enabled then
		scale.Scale = math.max(gui.AbsoluteSize.X / 1920, 0.65)
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
	mainapi:UpdateTextGUI(true)
	mainapi:UpdateBinds(true)
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

sidebar = Instance.new('Frame')
sidebar.Name = 'Navigation'
sidebar.Size = UDim2.fromOffset(176, 390)
sidebar.Position = UDim2.fromOffset(16, 24)
sidebar.BackgroundColor3 = Color3.fromRGB(3, 7, 14)
sidebar.BackgroundTransparency = 0.12
sidebar.BorderSizePixel = 0
sidebar.Parent = clickgui
addCorner(sidebar, UDim.new(0, 5))
local sidebarstroke = Instance.new('UIStroke')
sidebarstroke.Color = Color3.fromRGB(21, 28, 39)
sidebarstroke.Transparency = 0.2
sidebarstroke.Thickness = 1
sidebarstroke.Parent = sidebar
local sidebarlogo = Instance.new('ImageLabel')
sidebarlogo.Name = 'Logo'
sidebarlogo.Size = UDim2.fromOffset(145, 54)
sidebarlogo.Position = UDim2.fromOffset(14, 8)
sidebarlogo.BackgroundTransparency = 1
sidebarlogo.Image = getcustomasset('newvape/assets/liquidbounce/logo.png')
sidebarlogo.ScaleType = Enum.ScaleType.Fit
sidebarlogo.Parent = sidebar
local versionlabel = Instance.new('TextLabel')
versionlabel.Size = UDim2.new(1, -24, 0, 18)
versionlabel.Position = UDim2.fromOffset(12, 67)
versionlabel.BackgroundTransparency = 1
versionlabel.Text = 'NEXTGEN  •  ROBLOX'
versionlabel.TextXAlignment = Enum.TextXAlignment.Left
versionlabel.TextColor3 = Color3.fromRGB(100, 108, 122)
versionlabel.TextSize = 9
versionlabel.FontFace = uipallet.FontSemiBold
versionlabel.Parent = sidebar
local sideDivider = Instance.new('Frame')
sideDivider.Size = UDim2.new(1, -20, 0, 1)
sideDivider.Position = UDim2.fromOffset(10, 87)
sideDivider.BackgroundColor3 = Color3.fromRGB(24, 30, 41)
sideDivider.BorderSizePixel = 0
sideDivider.Parent = sidebar
categoryholder = Instance.new('Frame')
categoryholder.Name = 'Categories'
categoryholder.Size = UDim2.new(1, -12, 0, 270)
categoryholder.Position = UDim2.fromOffset(6, 94)
categoryholder.BackgroundTransparency = 1
categoryholder.Parent = sidebar
local categorylayout = Instance.new('UIListLayout')
categorylayout.SortOrder = Enum.SortOrder.LayoutOrder
categorylayout.Parent = categoryholder
local sidehint = Instance.new('TextLabel')
sidehint.Size = UDim2.new(1, -20, 0, 18)
sidehint.Position = UDim2.new(0, 10, 1, -24)
sidehint.BackgroundTransparency = 1
sidehint.Text = 'RIGHT SHIFT  •  TOGGLE'
sidehint.TextXAlignment = Enum.TextXAlignment.Left
sidehint.TextColor3 = Color3.fromRGB(82, 89, 102)
sidehint.TextSize = 9
sidehint.FontFace = uipallet.FontSemiBold
sidehint.Parent = sidebar

local searchframe = Instance.new('Frame')
searchframe.Name = 'Search'
searchframe.Size = UDim2.fromOffset(480, 36)
searchframe.Position = UDim2.new(0.5, -240, 0, 40)
searchframe.BackgroundColor3 = Color3.fromRGB(1, 4, 9)
searchframe.BackgroundTransparency = 0.03
searchframe.BorderSizePixel = 0
searchframe.ZIndex = 50
searchframe.Parent = clickgui
addCorner(searchframe, UDim.new(0, 5))
local searchstroke = Instance.new('UIStroke')
searchstroke.Name = 'Accent'
searchstroke.Color = uipallet.Main
searchstroke.Transparency = 0.15
searchstroke.Thickness = 1
searchstroke.Parent = searchframe
local searchicon = Instance.new('TextLabel')
searchicon.Size = UDim2.fromOffset(34, 36)
searchicon.BackgroundTransparency = 1
searchicon.ZIndex = 52
searchicon.Text = '⌕'
searchicon.TextColor3 = Color3.fromRGB(143, 148, 158)
searchicon.TextSize = 19
searchicon.FontFace = uipallet.Font
searchicon.Parent = searchframe
searchbox = Instance.new('TextBox')
searchbox.Name = 'Input'
searchbox.Size = UDim2.new(1, -46, 1, 0)
searchbox.Position = UDim2.fromOffset(36, 0)
searchbox.BackgroundTransparency = 1
searchbox.ZIndex = 52
searchbox.ClearTextOnFocus = false
searchbox.PlaceholderText = 'Search modules...'
searchbox.PlaceholderColor3 = Color3.fromRGB(91, 98, 111)
searchbox.Text = ''
searchbox.TextColor3 = Color3.fromRGB(229, 232, 239)
searchbox.TextSize = 13
searchbox.TextXAlignment = Enum.TextXAlignment.Left
searchbox.FontFace = uipallet.Font
searchbox.Parent = searchframe
searchresults = Instance.new('Frame')
searchresults.Name = 'Results'
searchresults.Size = UDim2.fromOffset(480, 0)
searchresults.Position = UDim2.fromOffset(0, 41)
searchresults.BackgroundColor3 = Color3.fromRGB(1, 4, 9)
searchresults.BackgroundTransparency = 0.02
searchresults.BorderSizePixel = 0
searchresults.ClipsDescendants = true
searchresults.ZIndex = 51
searchresults.Visible = false
searchresults.Parent = searchframe
addCorner(searchresults, UDim.new(0, 5))
local searchlayout = Instance.new('UIListLayout')
searchlayout.SortOrder = Enum.SortOrder.LayoutOrder
searchlayout.Parent = searchresults

local function refreshSearch()
	for _, object in searchresults:GetChildren() do
		if not object:IsA('UIListLayout') then object:Destroy() end
	end
	local query = searchbox.Text:lower():gsub('^%s+', ''):gsub('%s+$', '')
	if query == '' then
		searchresults.Visible = false
		searchresults.Size = UDim2.fromOffset(480, 0)
		return
	end
	local matches = {}
	for name, module in mainapi.Modules do
		if name:lower():find(query, 1, true) then table.insert(matches, module) end
	end
	if mainapi.Legit and mainapi.Legit.Modules then
		for name, module in mainapi.Legit.Modules do
			if name:lower():find(query, 1, true) then table.insert(matches, module) end
		end
	end
	table.sort(matches, function(a, b) return a.Name:lower() < b.Name:lower() end)
	local count = math.min(#matches, 8)
	for index = 1, count do
		local module = matches[index]
		local result = Instance.new('TextButton')
		result.Name = module.Name
		result.Size = UDim2.new(1, 0, 0, 29)
		result.BackgroundColor3 = Color3.fromRGB(1, 4, 9)
		result.BackgroundTransparency = 0.02
		result.BorderSizePixel = 0
		result.ZIndex = 52
		result.AutoButtonColor = false
		result.Text = '    '..module.Name
		result.TextXAlignment = Enum.TextXAlignment.Left
		result.TextColor3 = module.Enabled and uipallet.Main or Color3.fromRGB(205, 209, 217)
		result.TextSize = 12
		result.FontFace = uipallet.Font
		result.LayoutOrder = index
		result.Parent = searchresults
		local locate = Instance.new('TextLabel')
		locate.Size = UDim2.fromOffset(155, 29)
		locate.Position = UDim2.new(1, -165, 0, 0)
		locate.BackgroundTransparency = 1
		locate.ZIndex = 53
		locate.Text = module.CategoryObject and module.CategoryObject.DisplayName or module.Category
		locate.TextXAlignment = Enum.TextXAlignment.Right
		locate.TextColor3 = Color3.fromRGB(86, 93, 106)
		locate.TextSize = 10
		locate.FontFace = uipallet.Font
		locate.Parent = result
		result.MouseEnter:Connect(function() result.BackgroundColor3 = Color3.fromRGB(9, 14, 23) end)
		result.MouseLeave:Connect(function() result.BackgroundColor3 = Color3.fromRGB(1, 4, 9) end)
		result.MouseButton1Click:Connect(function()
			if module.CategoryObject then
				module.CategoryObject.Object.Visible = true
				module.CategoryObject:Expand(true, true)
				module.CategoryObject.Object.Position = UDim2.new(0.5, -101, 0, 118)
				module:SetExpanded(true)
			end
			searchbox.Text = ''
		end)
	end
	searchresults.Size = UDim2.fromOffset(480, count * 29)
	searchresults.Visible = count > 0
end
mainapi:Clean(searchbox:GetPropertyChangedSignal('Text'):Connect(refreshSearch))

local blatant = mainapi:CreateCategory({Name = 'Blatant'})
local combat = mainapi:CreateCategory({Name = 'Combat'})
local legitModules = mainapi.Legit.Modules
mainapi.Legit = mainapi:CreateCategory({
	Name = 'Legit',
	Legit = true,
	Modules = legitModules
})
local minigames = mainapi:CreateCategory({Name = 'Minigames'})
local render = mainapi:CreateCategory({Name = 'Render'})
local utility = mainapi:CreateCategory({Name = 'Utility'})
local world = mainapi:CreateCategory({Name = 'World'})
mainapi.Categories.Main = render
local clientsettings = render:CreateModule({Name = 'Client Settings'})

local guibind = {
	Bind = table.clone(mainapi.Keybind)
}
local guibindrow = Instance.new('TextButton')
guibindrow.Name = 'GUIBind'
guibindrow.Size = UDim2.new(1, 0, 0, 41)
guibindrow.BackgroundTransparency = 1
guibindrow.Text = ''
guibindrow.Parent = clientsettings.Children
local guibindaccent = Instance.new('Frame')
guibindaccent.Name = 'Accent'
guibindaccent.Size = UDim2.new(0, 2, 1, 0)
guibindaccent.BackgroundColor3 = uipallet.Main
guibindaccent.BorderSizePixel = 0
guibindaccent.Parent = guibindrow
local guibindbox = Instance.new('Frame')
guibindbox.Size = UDim2.new(1, -20, 1, -14)
guibindbox.Position = UDim2.fromOffset(10, 7)
guibindbox.BackgroundColor3 = uipallet.Main
guibindbox.BorderSizePixel = 0
guibindbox.Parent = guibindrow
addCorner(guibindbox, UDim.new(0, 3))
local guibindinner = Instance.new('Frame')
guibindinner.Size = UDim2.new(1, -2, 1, -2)
guibindinner.Position = UDim2.fromOffset(1, 1)
guibindinner.BackgroundColor3 = Color3.fromRGB(1, 4, 9)
guibindinner.BorderSizePixel = 0
guibindinner.Parent = guibindbox
addCorner(guibindinner, UDim.new(0, 3))
local guibindlabel = Instance.new('TextLabel')
guibindlabel.Size = UDim2.fromScale(1, 1)
guibindlabel.BackgroundTransparency = 1
guibindlabel.Text = 'GUI Bind: '..table.concat(mainapi.Keybind, ' + ')
guibindlabel.TextColor3 = Color3.fromRGB(228, 231, 238)
guibindlabel.TextSize = 12
guibindlabel.FontFace = uipallet.FontSemiBold
guibindlabel.Parent = guibindinner
function guibind:SetBind(keys, mouse)
	if type(keys) ~= 'table' or keys.Mobile then return end
	self.Bind = #keys > 0 and table.clone(keys) or {'RightShift'}
	mainapi.Keybind = table.clone(self.Bind)
	guibindlabel.Text = 'GUI Bind: '..table.concat(self.Bind, ' + ')
	mainapi:UpdateBinds()
end
guibindrow.MouseButton1Click:Connect(function()
	guibindlabel.Text = 'Press any key'
	mainapi.Binding = guibind
end)
mainapi.GUIBind = guibind

mainapi.Notifications = clientsettings:CreateToggle({Name = 'Notifications', Default = true})
mainapi.ToggleNotifications = clientsettings:CreateToggle({Name = 'Toggle notifications', Default = true})
mainapi.MultiKeybind = clientsettings:CreateToggle({Name = 'Multi keybinds'})
local guibindindicator = clientsettings:CreateToggle({Name = 'GUI bind indicator', Default = true})
local function refreshEntityLibrary()
	if mainapi.Libraries.entity and mainapi.Libraries.entity.Running then
		mainapi.Libraries.entity.refresh()
	end
end
local teamsbyserver = clientsettings:CreateToggle({
	Name = 'Teams by server',
	Default = true,
	Function = refreshEntityLibrary
})
local useteamcolor = clientsettings:CreateToggle({
	Name = 'Use team color',
	Default = true,
	Function = refreshEntityLibrary
})
render.Options['GUI bind indicator'] = guibindindicator
render.Options['Teams by server'] = teamsbyserver
render.Options['Use team color'] = useteamcolor
mainapi.Blur = clientsettings:CreateToggle({
	Name = 'Background blur',
	Default = true,
	Function = function()
		if mainapi.Blur and mainapi.Blur.Enabled ~= nil then mainapi:BlurCheck() end
	end
})
mainapi.Scale = clientsettings:CreateToggle({
	Name = 'Auto scale',
	Default = true,
	Function = function(enabled)
		scale.Scale = enabled and math.max(gui.AbsoluteSize.X / 1920, 0.65) or 1
	end
})
clientsettings:CreateDivider('Interface')
clientsettings:CreateDropdown({
	Name = 'GUI Theme',
	List = {'LiquidBounce', 'New', 'Old', 'Rise'},
	Function = function(value, mouse)
		if mouse then mainapi:Reinject(value) end
	end
})
clientsettings:CreateButton({
	Name = 'Reinject',
	Function = function()
		mainapi:Reinject()
	end
})

clientsettings:CreateDivider('Friends, targets and profiles')
local friendsupdate = Instance.new('BindableEvent')
local friendscolorupdate = Instance.new('BindableEvent')
local friendscolor = {Hue = 0.62, Sat = 0.72, Value = 1}
local friends
local function updateFriends()
	friendsupdate:Fire()
	friendscolorupdate:Fire(friendscolor.Hue, friendscolor.Sat, friendscolor.Value)
end
friends = clientsettings:CreateTextList({
	Name = 'Friends',
	Placeholder = 'Roblox username',
	Color = uipallet.Main,
	Function = updateFriends
})
friends.Update = friendsupdate
friends.ColorUpdate = friendscolorupdate
friends.Options = {}
local recolorfriends = clientsettings:CreateToggle({
	Name = 'Recolor visuals',
	Default = true,
	Function = updateFriends
})
friendscolor = clientsettings:CreateColorSlider({
	Name = 'Friends color',
	DefaultHue = friendscolor.Hue,
	DefaultSat = friendscolor.Sat,
	DefaultValue = friendscolor.Value,
	Function = function(hue, sat, value)
		if friends.SetListColor then friends:SetListColor(Color3.fromHSV(hue, sat, value)) end
		friendscolorupdate:Fire(hue, sat, value)
	end
})
local usefriends = clientsettings:CreateToggle({
	Name = 'Use friends',
	Default = true,
	Function = updateFriends
})
friends.Options['Recolor visuals'] = recolorfriends
friends.Options['Friends color'] = friendscolor
friends.Options['Use friends'] = usefriends
mainapi:Clean(friendsupdate)
mainapi:Clean(friendscolorupdate)
mainapi.Categories.Friends = friends

local targetsupdate = Instance.new('BindableEvent')
local targets
targets = clientsettings:CreateTextList({
	Name = 'Targets',
	Placeholder = 'Roblox username',
	Color = uipallet.Main,
	Function = function()
		targetsupdate:Fire()
	end
})
targets.Update = targetsupdate
mainapi:Clean(targetsupdate)
mainapi.Categories.Targets = targets

local profiles
local profileUpdating = false
local profileOption = clientsettings:CreateDropdown({
	Name = 'Profile',
	List = {'default'},
	Function = function(value)
		if profileUpdating or mainapi.Loading or mainapi.Loaded ~= true or value == mainapi.Profile then return end
		mainapi:Save()
		mainapi:Load(true, value)
	end
})
local profileName = clientsettings:CreateTextBox({
	Name = 'Profile name',
	Placeholder = 'New profile name'
})
profiles = {
	Type = 'Compatibility',
	Options = {Profile = profileOption},
	Object = profileOption.Object,
	List = mainapi.Profiles,
	ListEnabled = {}
}
function profiles:ChangeValue()
	self.List = mainapi.Profiles
	local names = {}
	for _, data in mainapi.Profiles do
		table.insert(names, data.Name)
	end
	if #names == 0 then names = {'default'} end
	profileUpdating = true
	profileOption:Change(names)
	profileOption:SetValue(mainapi.Profile)
	profileUpdating = false
end
clientsettings:CreateButton({
	Name = 'Save profile',
	Function = function()
		local name = tostring(profileName.Value or ''):gsub('^%s+', ''):gsub('%s+$', '')
		if name == '' then
			mainapi:CreateNotification('LiquidBounce', 'Enter a profile name first.', 2, 'warning')
			return
		end
		local found = false
		for _, data in mainapi.Profiles do
			if data.Name == name then found = true break end
		end
		if not found then table.insert(mainapi.Profiles, {Name = name, Bind = {}}) end
		mainapi.Profile = name
		profiles:ChangeValue()
		mainapi:Save()
		mainapi:CreateNotification('LiquidBounce', 'Saved profile '..name..'.', 2)
	end
})
mainapi.Categories.Profiles = profiles

textguiholder = Instance.new('Frame')
textguiholder.Name = 'LiquidBounceTextGUI'
textguiholder.Size = UDim2.fromOffset(300, 500)
textguiholder.AnchorPoint = Vector2.new(1, 0)
textguiholder.Position = UDim2.new(1, -12, 0, 8)
textguiholder.BackgroundTransparency = 1
textguiholder.Visible = false
textguiholder.Parent = scaledgui
local textguilayout = Instance.new('UIListLayout')
textguilayout.Name = 'Layout'
textguilayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
textguilayout.SortOrder = Enum.SortOrder.LayoutOrder
textguilayout.Padding = UDim.new(0, 2)
textguilayout.Parent = textguiholder
textguilogo = Instance.new('ImageLabel')
textguilogo.Name = 'Watermark'
textguilogo.Size = UDim2.fromOffset(132, 50)
textguilogo.Position = UDim2.fromOffset(12, 8)
textguilogo.BackgroundTransparency = 1
textguilogo.Image = getcustomasset('newvape/assets/liquidbounce/logo.png')
textguilogo.ScaleType = Enum.ScaleType.Fit
textguilogo.Visible = false
textguilogo.ZIndex = 5
textguilogo.Parent = scaledgui

bindsholder = Instance.new('Frame')
bindsholder.Name = 'LiquidBounceBinds'
bindsholder.Size = UDim2.fromOffset(144, 30)
bindsholder.Position = UDim2.fromOffset(152, 8)
bindsholder.BackgroundColor3 = Color3.fromRGB(2, 5, 10)
bindsholder.BackgroundTransparency = 0.01
bindsholder.BorderSizePixel = 0
bindsholder.Active = true
bindsholder.ClipsDescendants = true
bindsholder.Visible = false
bindsholder.ZIndex = 5
bindsholder.Parent = scaledgui
addCorner(bindsholder, UDim.new(0, 3))
local bindsstroke = Instance.new('UIStroke')
bindsstroke.Color = Color3.fromRGB(24, 31, 43)
bindsstroke.Transparency = 0.2
bindsstroke.Thickness = 1
bindsstroke.Parent = bindsholder
local bindsheader = Instance.new('TextLabel')
bindsheader.Name = 'Header'
bindsheader.Size = UDim2.new(1, 0, 0, 25)
bindsheader.BackgroundColor3 = Color3.fromRGB(4, 7, 13)
bindsheader.BackgroundTransparency = 0.02
bindsheader.BorderSizePixel = 0
bindsheader.Text = '  Binds'
bindsheader.TextXAlignment = Enum.TextXAlignment.Left
bindsheader.TextColor3 = Color3.fromRGB(239, 241, 246)
bindsheader.TextTransparency = 0
bindsheader.TextSize = 13
bindsheader.FontFace = uipallet.FontSemiBold
bindsheader.ZIndex = 8
bindsheader.Parent = bindsholder
local bindsicon = Instance.new('TextLabel')
bindsicon.Size = UDim2.fromOffset(24, 25)
bindsicon.Position = UDim2.new(1, -27, 0, 0)
bindsicon.BackgroundTransparency = 1
bindsicon.Text = '⌨'
bindsicon.TextColor3 = Color3.fromRGB(178, 183, 193)
bindsicon.TextTransparency = 0
bindsicon.TextSize = 12
bindsicon.FontFace = uipallet.Font
bindsicon.ZIndex = 9
bindsicon.Parent = bindsholder
makeDraggable(bindsholder)
textgui = render:CreateModule({
	Name = 'Text GUI',
	Function = function() mainapi:UpdateTextGUI(true) end
})
textgui.WatermarkOption = textgui:CreateToggle({Name = 'Watermark', Default = true, Function = function() mainapi:UpdateTextGUI(true) end})
textgui.BackgroundOption = textgui:CreateToggle({Name = 'Background', Default = true, Function = function() mainapi:UpdateTextGUI(true) end})
textgui.LowercaseOption = textgui:CreateToggle({Name = 'Lowercase', Function = function() mainapi:UpdateTextGUI(true) end})
textgui.SortOption = textgui:CreateDropdown({Name = 'Sort', List = {'Length', 'Alphabetical'}, Function = function() mainapi:UpdateTextGUI(true) end})
mainapi.Categories.TextGUI = textgui
bindsmodule = render:CreateModule({
	Name = 'Binds',
	Function = function() mainapi:UpdateBinds(true) end
})
mainapi.Categories.Binds = bindsmodule

local targetframe = Instance.new('Frame')
targetframe.Name = 'LiquidBounceTargetInfo'
targetframe.Size = UDim2.fromOffset(250, 72)
targetframe.Position = UDim2.new(0.5, -125, 1, -112)
targetframe.BackgroundColor3 = Color3.fromRGB(2, 5, 10)
targetframe.BackgroundTransparency = 0.08
targetframe.BorderSizePixel = 0
targetframe.Visible = false
targetframe.Parent = scaledgui
addCorner(targetframe, UDim.new(0, 4))
makeDraggable(targetframe, targetframe)
local targetaccent = Instance.new('Frame')
targetaccent.Name = 'Accent'
targetaccent.Size = UDim2.new(0, 3, 1, 0)
targetaccent.BackgroundColor3 = uipallet.Main
targetaccent.BorderSizePixel = 0
targetaccent.Parent = targetframe
local targetavatar = Instance.new('ImageLabel')
targetavatar.Size = UDim2.fromOffset(52, 52)
targetavatar.Position = UDim2.fromOffset(12, 10)
targetavatar.BackgroundColor3 = Color3.fromRGB(10, 15, 23)
targetavatar.BorderSizePixel = 0
targetavatar.Image = 'rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150'
targetavatar.Parent = targetframe
addCorner(targetavatar, UDim.new(0, 3))
local targetname = Instance.new('TextLabel')
targetname.Size = UDim2.new(1, -82, 0, 22)
targetname.Position = UDim2.fromOffset(74, 11)
targetname.BackgroundTransparency = 1
targetname.Text = 'Target'
targetname.TextXAlignment = Enum.TextXAlignment.Left
targetname.TextColor3 = Color3.fromRGB(235, 238, 244)
targetname.TextSize = 14
targetname.TextTruncate = Enum.TextTruncate.AtEnd
targetname.FontFace = uipallet.FontSemiBold
targetname.Parent = targetframe
local healthbackground = Instance.new('Frame')
healthbackground.Size = UDim2.new(1, -91, 0, 4)
healthbackground.Position = UDim2.fromOffset(74, 42)
healthbackground.BackgroundColor3 = Color3.fromRGB(35, 41, 51)
healthbackground.BorderSizePixel = 0
healthbackground.Parent = targetframe
addCorner(healthbackground, UDim.new(1, 0))
local healthfill = Instance.new('Frame')
healthfill.Name = 'Accent'
healthfill.Size = UDim2.fromScale(1, 1)
healthfill.BackgroundColor3 = uipallet.Main
healthfill.BorderSizePixel = 0
healthfill.Parent = healthbackground
addCorner(healthfill, UDim.new(1, 0))
local healthlabel = Instance.new('TextLabel')
healthlabel.Size = UDim2.new(1, -82, 0, 16)
healthlabel.Position = UDim2.fromOffset(74, 50)
healthlabel.BackgroundTransparency = 1
healthlabel.Text = '100 HP'
healthlabel.TextXAlignment = Enum.TextXAlignment.Left
healthlabel.TextColor3 = Color3.fromRGB(126, 132, 144)
healthlabel.TextSize = 10
healthlabel.FontFace = uipallet.Font
healthlabel.Parent = targetframe
local targetinfo
local targetinfomodule
targetinfomodule = render:CreateModule({
	Name = 'Target Info',
	Function = function(enabled)
		if enabled then
			task.spawn(function()
				repeat
					if targetinfo then targetinfo:UpdateInfo() end
					task.wait()
				until not targetinfomodule.Enabled or mainapi.Loaded == nil
			end)
		else
			targetframe.Visible = false
		end
	end
})
local targetdisplayname = targetinfomodule:CreateToggle({Name = 'Use display name', Default = true})
targetinfo = {
	Targets = {},
	Object = targetframe
}
function targetinfo:UpdateInfo()
	local selected
	local newest = tick()
	for entity, expires in self.Targets do
		if expires < tick() then
			self.Targets[entity] = nil
		elseif expires > newest then
			selected = entity
			newest = expires
		end
	end
	targetframe.Visible = targetinfomodule.Enabled and (selected ~= nil or clickgui.Visible)
	if not selected then return end
	local playerObject = selected.Player
	local characterObject = selected.Character
	local display = playerObject and (targetdisplayname.Enabled and playerObject.DisplayName or playerObject.Name)
		or characterObject and characterObject.Name
		or 'Target'
	targetname.Text = display
	if playerObject then targetavatar.Image = 'rbxthumb://type=AvatarHeadShot&id='..playerObject.UserId..'&w=150&h=150' end
	local health = tonumber(selected.Health) or 0
	local maxHealth = math.max(tonumber(selected.MaxHealth) or 100, 1)
	healthlabel.Text = math.round(health)..' HP'
	tween:Tween(healthfill, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(math.clamp(health / maxHealth, 0, 1), 1)
	})
end
mainapi.Libraries.targetinfo = targetinfo

mainapi:Clean(inputService.InputBegan:Connect(function(inputObj)
	if not inputService:GetFocusedTextBox() and inputObj.KeyCode ~= Enum.KeyCode.Unknown then
		if inputObj.KeyCode == Enum.KeyCode.F and (inputService:IsKeyDown(Enum.KeyCode.LeftControl) or inputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			if not clickgui.Visible then clickgui.Visible = true end
			searchbox:CaptureFocus()
			return
		end
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
			--tooltip.Visible = false
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
		if mainapi.Legit and mainapi.Legit.Modules then
			for i, v in mainapi.Legit.Modules do
				if checkKeybinds(mainapi.HeldKeybinds, v.Bind, inputObj.KeyCode.Name) then
					toggled = true
					if mainapi.ToggleNotifications.Enabled then
						mainapi:CreateNotification('Module Toggled', i..' has been '..(not v.Enabled and 'enabled' or 'disabled')..'.', 0.75)
					end
					v:Toggle(true)
				end
			end
		end
		if toggled then
			mainapi:UpdateTextGUI()
			mainapi:UpdateBinds()
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
