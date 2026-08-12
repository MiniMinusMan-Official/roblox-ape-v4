repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('Vape', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))
local httpService = cloneref(game:GetService('HttpService'))

local sourceRef = isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or 'main'
local sourceRoot = 'https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/'..sourceRef..'/src/'
local sourceTree

local function fetchSource(path)
	local suc, res = pcall(function()
		return game:HttpGet(sourceRoot..path:gsub(' ', '%%20'), true)
	end)
	if not suc or res == '404: Not Found' then
		error(res)
	end
	return res
end

local function getSourceTree()
	if sourceTree then return sourceTree end
	local suc, res = pcall(function()
		return game:HttpGet(
			'https://api.github.com/repos/MiniMinusMan-Official/roblox-ape-v4/git/trees/'..sourceRef..'?recursive=1',
			true
		)
	end)
	if not suc then error(res) end

	res = httpService:JSONDecode(res)
	if res.truncated then
		error('GitHub returned a truncated source tree')
	end
	sourceTree = res.tree or {}
	return sourceTree
end

local function listSourceFiles(folder)
	local prefix = 'src/'..folder
	local files = {}
	for _, item in getSourceTree() do
		if item.type == 'blob' and item.path:sub(1, #prefix) == prefix and item.path:sub(-4) == '.lua' then
			table.insert(files, item.path:sub(5))
		end
	end
	table.sort(files)
	return files
end

local function validAsset(path)
	if not isfile(path) then return false end
	local suc, data = pcall(readfile, path)
	if not suc or type(data) ~= 'string' or #data < 8 then return false end
	if path:lower():sub(-4) == '.png' then
		return data:sub(1, 8) == '\137PNG\r\n\26\n'
	end
	return true
end

local function downloadGUIAssets(name)
	local prefix = 'src/guis/'..name..'/assets/'
	local cacheFolder = 'newvape/assets/'..name..'/source-cache'
	local assetLoader = getcustomasset or getsynasset
	if not isfolder(cacheFolder) then makefolder(cacheFolder) end
	shared.VapeAssetPaths = shared.VapeAssetPaths or {}

	for _, item in getSourceTree() do
		if item.type == 'blob' and item.path:sub(1, #prefix) == prefix then
			local relative = item.path:sub(#prefix + 1)
			local logicalPath = 'newvape/assets/'..name..'/'..relative
			local cacheName = relative:gsub('[/\\]', '_')
			local cachePath = cacheFolder..'/'..item.sha:sub(1, 12)..'_'..cacheName

			if not validAsset(cachePath) then
				writefile(cachePath, fetchSource(item.path:sub(5)))
			end
			shared.VapeAssetPaths[logicalPath] = cachePath
			if assetLoader then pcall(assetLoader, cachePath) end
		end
	end

	-- Give executors one frame to observe newly written image/font files.
	task.wait()
end

local function indentSource(source, indent)
	return indent..source:gsub('\n', '\n'..indent)
end

local function buildGUI(name)
	local source = fetchSource('guis/'..name..'/gui.lua')
	local components = {}

	for _, path in listSourceFiles('guis/'..name..'/components/') do
		local componentName = path:match('([^/]+)%.lua$')
		local body = indentSource(fetchSource(path), '\t\t')
		table.insert(components, '\t'..componentName..' = function(optionsettings, children, api)\n'..body..'\n\tend,')
	end

	local count
	source, count = source:gsub('%-%-Components', function()
		return '--Components\n'..table.concat(components, '\n')
	end, 1)
	if count ~= 1 then
		error('Missing --Components marker in guis/'..name..'/gui.lua')
	end
	return source
end

local function buildUniversal()
	local folder = 'games/universal - base/'
	local source = fetchSource(folder..'base.lua')

	for _, path in listSourceFiles(folder) do
		if path ~= folder..'base.lua' then
			local body = indentSource(fetchSource(path), '\t')
			source ..= '\n\n-- BEGIN '..path:sub(#folder + 1)..'\n;(function()\n'..body..'\nend)()\n-- END '..path:sub(#folder + 1)
		end
	end
	return source
end

local function downloadFile(path, func)
	if not isfile(path) then
		local relativePath = select(1, path:gsub('^newvape/', ''))
		local gui = relativePath:match('^guis/([^/]+)%.lua$')
		local res = gui and buildGUI(gui)
			or relativePath == 'games/universal.lua' and buildUniversal()
			or fetchSource(relativePath)
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				shared.vapereload = true
				if shared.VapeDeveloper then
					loadstring(readfile('newvape/loader.lua'), 'loader')()
				else
					loadstring(game:HttpGet('https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/main/src/loader.lua', true), 'loader')()
				end
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = 'shared.VapeCustomProfile = "'..shared.VapeCustomProfile..'"\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('newvape/profiles/gui.txt') then
	writefile('newvape/profiles/gui.txt', 'new')
end
local gui = readfile('newvape/profiles/gui.txt')

if not isfolder('newvape/assets/'..gui) then
	makefolder('newvape/assets/'..gui)
end
downloadGUIAssets(gui)
vape = loadstring(downloadFile('newvape/guis/'..gui..'.lua'), 'gui')()
shared.vape = vape

if not shared.VapeIndependent then
	loadstring(downloadFile('newvape/games/universal.lua'), 'universal')()
	if isfile('newvape/games/'..game.PlaceId..'.lua') then
		loadstring(readfile('newvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
	else
		if not shared.VapeDeveloper then
			local suc, res = pcall(function()
				return game:HttpGet('https://raw.githubusercontent.com/MiniMinusMan-Official/roblox-ape-v4/main/src/games/'..game.PlaceId..'.lua', true)
			end)
			if suc and res ~= '404: Not Found' then
				loadstring(downloadFile('newvape/games/'..game.PlaceId..'.lua'), tostring(game.PlaceId))(...)
			end
		end
	end
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end
