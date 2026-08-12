local entitylib = {
	isAlive = false,
	character = {},
	List = {},
	Connections = {},
	PlayerConnections = {},
	EntityThreads = {},
	Running = false,
	Events = setmetatable({}, {
		__index = function(self, ind)
			self[ind] = {
				Connections = {},
				Connect = function(rself, func)
					table.insert(rself.Connections, func)
					return {
						Disconnect = function()
							local rind = table.find(rself.Connections, func)
							if rind then
								table.remove(rself.Connections, rind)
							end
						end
					}
				end,
				Fire = function(rself, ...)
					for _, v in rself.Connections do
						task.spawn(v, ...)
					end
				end,
				Destroy = function(rself)
					table.clear(rself.Connections)
					table.clear(rself)
				end
			}

			return self[ind]
		end
	})
}

local cloneref = cloneref or function(obj)
	return obj
end

local playersService = cloneref(game:GetService('Players'))
local inputService = cloneref(game:GetService('UserInputService'))
local lplr = playersService.LocalPlayer
local gameCamera = workspace.CurrentCamera

local function getMousePosition()
	if inputService.TouchEnabled then
		return gameCamera.ViewportSize / 2
	end

	return inputService.GetMouseLocation(inputService)
end

local function loopClean(tbl)
	for i, v in tbl do
		if type(v) == 'table' then
			loopClean(v)
		end

		tbl[i] = nil
	end
end

local function waitForChildOfType(obj, name, timeout, prop)
	local checktick = tick() + timeout
	local returned

	repeat
		returned = prop and obj[name] or obj:FindFirstChildOfClass(name)
		if returned or checktick < tick() then break end
		task.wait()
	until false

	return returned
end

entitylib.targetCheck = function(entity)
	if entity.TeamCheck then
		return entity:TeamCheck()
	end

	if entity.NPC then return true end
	if not lplr.Team then return true end
	if not entity.Player.Team then return true end
	if entity.Player.Team ~= lplr.Team then return true end

	return #entity.Player.Team:GetPlayers()
		== #playersService:GetPlayers()
end

entitylib.getUpdateConnections = function(entity)
	local humanoid = entity.Humanoid

	return {
		humanoid:GetPropertyChangedSignal('Health'),
		humanoid:GetPropertyChangedSignal('MaxHealth')
	}
end

entitylib.isVulnerable = function(entity)
	return entity.Health > 0
		and not entity.Character.FindFirstChildWhichIsA(
			entity.Character,
			'ForceField'
		)
end

entitylib.getEntityColor = function(entity)
	entity = entity.Player

	return entity
		and tostring(entity.TeamColor) ~= 'White'
		and entity.TeamColor.Color
		or nil
end

entitylib.IgnoreObject = RaycastParams.new()
entitylib.IgnoreObject.RespectCanCollide = true

entitylib.Wallcheck = function(origin, position, ignoreobject)
	if typeof(ignoreobject) ~= 'Instance' then
		local ignorelist = {
			gameCamera,
			lplr.Character
		}

		for _, entity in entitylib.List do
			if entity.Targetable then
				table.insert(ignorelist, entity.Character)
			end
		end

		if typeof(ignoreobject) == 'table' then
			for _, obj in ignoreobject do
				table.insert(ignorelist, obj)
			end
		end

		ignoreobject = entitylib.IgnoreObject
		ignoreobject.FilterDescendantsInstances = ignorelist
	end

	return workspace.Raycast(
		workspace,
		origin,
		position - origin,
		ignoreobject
	)
end

entitylib.EntityMouse = function(entitysettings)
	if entitylib.isAlive then
		local mouseLocation = entitysettings.MouseOrigin
			or getMousePosition()

		local sortingTable = {}

		for _, entity in entitylib.List do
			if not entitysettings.Players and entity.Player then
				continue
			end

			if not entitysettings.NPCs and entity.NPC then
				continue
			end

			if not entity.Targetable then
				continue
			end

			local part = entity[entitysettings.Part]
			if not part or not part.Parent then
				continue
			end

			local position, visible = gameCamera.WorldToViewportPoint(
				gameCamera,
				part.Position
			)

			if not visible then
				continue
			end

			local magnitude = (
				mouseLocation
				- Vector2.new(position.X, position.Y)
			).Magnitude

			if magnitude > entitysettings.Range then
				continue
			end

			if entitylib.isVulnerable(entity) then
				table.insert(sortingTable, {
					Entity = entity,
					Magnitude = entity.Target and -1 or magnitude
				})
			end
		end

		table.sort(
			sortingTable,
			entitysettings.Sort or function(a, b)
				return a.Magnitude < b.Magnitude
			end
		)

		for _, value in sortingTable do
			local part = value.Entity[entitysettings.Part]

			if entitysettings.Wallcheck then
				if entitylib.Wallcheck(
					entitysettings.Origin,
					part.Position,
					entitysettings.Wallcheck
				) then
					continue
				end
			end

			table.clear(entitysettings)
			table.clear(sortingTable)

			return value.Entity
		end

		table.clear(sortingTable)
	end

	table.clear(entitysettings)
end

entitylib.EntityPosition = function(entitysettings)
	if entitylib.isAlive then
		local localPosition = entitysettings.Origin
			or entitylib.character.HumanoidRootPart.Position

		local sortingTable = {}

		for _, entity in entitylib.List do
			if not entitysettings.Players and entity.Player then
				continue
			end

			if not entitysettings.NPCs and entity.NPC then
				continue
			end

			if not entity.Targetable then
				continue
			end

			local part = entity[entitysettings.Part]
			if not part or not part.Parent then
				continue
			end

			local magnitude = (
				part.Position - localPosition
			).Magnitude

			if magnitude > entitysettings.Range then
				continue
			end

			if entitylib.isVulnerable(entity) then
				table.insert(sortingTable, {
					Entity = entity,
					Magnitude = entity.Target and -1 or magnitude
				})
			end
		end

		table.sort(
			sortingTable,
			entitysettings.Sort or function(a, b)
				return a.Magnitude < b.Magnitude
			end
		)

		for _, value in sortingTable do
			local part = value.Entity[entitysettings.Part]

			if entitysettings.Wallcheck then
				if entitylib.Wallcheck(
					localPosition,
					part.Position,
					entitysettings.Wallcheck
				) then
					continue
				end
			end

			table.clear(entitysettings)
			table.clear(sortingTable)

			return value.Entity
		end

		table.clear(sortingTable)
	end

	table.clear(entitysettings)
end

entitylib.AllPosition = function(entitysettings)
	local returned = {}

	if entitylib.isAlive then
		local localPosition = entitysettings.Origin
			or entitylib.character.HumanoidRootPart.Position

		local sortingTable = {}

		for _, entity in entitylib.List do
			if not entitysettings.Players and entity.Player then
				continue
			end

			if not entitysettings.NPCs and entity.NPC then
				continue
			end

			if not entity.Targetable then
				continue
			end

			local part = entity[entitysettings.Part]
			if not part or not part.Parent then
				continue
			end

			local magnitude = (
				part.Position - localPosition
			).Magnitude

			if magnitude > entitysettings.Range then
				continue
			end

			if entitylib.isVulnerable(entity) then
				table.insert(sortingTable, {
					Entity = entity,
					Magnitude = entity.Target and -1 or magnitude
				})
			end
		end

		table.sort(
			sortingTable,
			entitysettings.Sort or function(a, b)
				return a.Magnitude < b.Magnitude
			end
		)

		for _, value in sortingTable do
			local part = value.Entity[entitysettings.Part]

			if entitysettings.Wallcheck then
				if entitylib.Wallcheck(
					localPosition,
					part.Position,
					entitysettings.Wallcheck
				) then
					continue
				end
			end

			table.insert(returned, value.Entity)

			if #returned >= (entitysettings.Limit or math.huge) then
				break
			end
		end

		table.clear(sortingTable)
	end

	table.clear(entitysettings)
	return returned
end

entitylib.getEntity = function(char)
	for index, entity in entitylib.List do
		if entity.Player == char or entity.Character == char then
			return entity, index
		end
	end
end

entitylib.addEntity = function(char, plr, teamfunc, spawntime)
	if not char then
		return
	end

	entitylib.EntityThreads[char] = task.spawn(function()
		local hum = waitForChildOfType(
			char,
			'Humanoid',
			10
		)

		local humrootpart = hum
			and waitForChildOfType(
				hum,
				'RootPart',
				workspace.StreamingEnabled and 9e9 or 10,
				true
			)

		local head = char:WaitForChild('Head', 10)
			or humrootpart

		if hum and humrootpart then
			local entity = {
				Connections = {},
				Character = char,
				Health = hum.Health,
				Head = head,
				Humanoid = hum,
				HumanoidRootPart = humrootpart,

				HipHeight = hum.HipHeight
					+ humrootpart.Size.Y / 2
					+ (
						hum.RigType
							== Enum.HumanoidRigType.R6
						and 2
						or 0
					),

				MaxHealth = hum.MaxHealth,
				NPC = plr == nil,
				Player = plr,
				RootPart = humrootpart,
				SpawnTime = spawntime or 0,
				TeamCheck = teamfunc
			}

			if plr == lplr then
				entitylib.character = entity
				entitylib.isAlive = true
				entitylib.Events.LocalAdded:Fire(entity)
			else
				entity.Targetable = entitylib.targetCheck(entity)

				for _, connection in entitylib.getUpdateConnections(entity) do
					table.insert(
						entity.Connections,
						connection:Connect(function()
							entity.Health = hum.Health
							entity.MaxHealth = hum.MaxHealth

							entitylib.Events.EntityUpdated:Fire(
								entity
							)
						end)
					)
				end

				table.insert(entitylib.List, entity)
				entitylib.Events.EntityAdded:Fire(entity)
			end

			-- Some games reuse the same Character after death and replace
			-- the Humanoid, root part or head. Refresh the cached entity
			-- whenever that happens.
			local refreshQueued = false

			local function queueRefresh()
				if refreshQueued then
					return
				end

				refreshQueued = true

				task.defer(function()
					refreshQueued = false

					local current

					if plr == lplr then
						current = entitylib.isAlive
							and entitylib.character
							or nil
					else
						current = entitylib.getEntity(
							plr or char
						)
					end

					-- The entity was already removed by a normal respawn.
					if current ~= entity then
						return
					end

					local newHumanoid =
						char:FindFirstChildOfClass('Humanoid')

					local newRootPart = newHumanoid
						and newHumanoid.RootPart

					local newHead =
						char:FindFirstChild('Head')

					if newHumanoid ~= hum
						or newRootPart ~= humrootpart
						or newHead ~= head then

						entitylib.refreshEntity(
							char,
							plr,
							spawntime
						)
					end
				end)
			end

			table.insert(
				entity.Connections,
				char.ChildRemoved:Connect(function(part)
					if part == hum
						or part == humrootpart
						or part == head
						or part:IsA('Humanoid')
						or part.Name == 'HumanoidRootPart'
						or part.Name == 'Head' then

						queueRefresh()
					end
				end)
			)

			table.insert(
				entity.Connections,
				char.ChildAdded:Connect(function(part)
					if part:IsA('Humanoid')
						or part.Name == 'HumanoidRootPart'
						or part.Name == 'Head' then

						queueRefresh()
					end
				end)
			)
		end

		entitylib.EntityThreads[char] = nil
	end)
end

entitylib.removeEntity = function(char, isLocal)
	if isLocal then
		if entitylib.isAlive then
			entitylib.isAlive = false

			for _, connection in entitylib.character.Connections do
				connection:Disconnect()
			end

			table.clear(entitylib.character.Connections)

			entitylib.Events.LocalRemoved:Fire(
				entitylib.character
			)
		end

		return
	end

	if char then
		if entitylib.EntityThreads[char] then
			task.cancel(entitylib.EntityThreads[char])
			entitylib.EntityThreads[char] = nil
		end

		local entity, index = entitylib.getEntity(char)

		if index then
			for _, connection in entity.Connections do
				connection:Disconnect()
			end

			table.clear(entity.Connections)
			table.remove(entitylib.List, index)
			entitylib.Events.EntityRemoved:Fire(entity)
		end
	end
end

entitylib.refreshEntity = function(char, plr, spawntime)
	local teamfunc

	if plr == lplr then
		if entitylib.isAlive then
			local entity = entitylib.character
			teamfunc = entity.TeamCheck

			entitylib.removeEntity(
				entity.Character,
				true
			)
		end
	elseif plr then
		-- Remove every stale entry belonging to this player.
		local entity = entitylib.getEntity(plr)

		while entity do
			teamfunc = teamfunc or entity.TeamCheck
			entitylib.removeEntity(entity.Character)
			entity = entitylib.getEntity(plr)
		end
	else
		local entity = entitylib.getEntity(char)

		if entity then
			teamfunc = entity.TeamCheck
			entitylib.removeEntity(entity.Character)
		end
	end

	entitylib.addEntity(
		char,
		plr,
		teamfunc,
		spawntime
	)
end

entitylib.addPlayer = function(plr)
	if plr.Character then
		entitylib.refreshEntity(
			plr.Character,
			plr
		)
	end

	entitylib.PlayerConnections[plr] = {
		plr.CharacterAdded:Connect(function(char)
			entitylib.refreshEntity(
				char,
				plr,
				os.clock() + 0.4
			)
		end),

		plr.CharacterRemoving:Connect(function(char)
			entitylib.removeEntity(
				char,
				plr == lplr
			)
		end),

		plr:GetPropertyChangedSignal('Team'):Connect(function()
			if plr == lplr then
				local cloned =
					table.clone(entitylib.List)

				for _, entity in cloned do
					if entity.Targetable
						~= entitylib.targetCheck(entity) then

						entitylib.refreshEntity(
							entity.Character,
							entity.Player
						)
					end
				end

				table.clear(cloned)
			else
				local entity =
					entitylib.getEntity(plr)

				if entity then
					entitylib.refreshEntity(
						entity.Character,
						plr
					)
				end
			end
		end)
	}
end

entitylib.removePlayer = function(plr)
	if entitylib.PlayerConnections[plr] then
		for _, connection in entitylib.PlayerConnections[plr] do
			connection:Disconnect()
		end

		table.clear(
			entitylib.PlayerConnections[plr]
		)

		entitylib.PlayerConnections[plr] = nil
	end

	entitylib.removeEntity(plr)
end

entitylib.start = function()
	if entitylib.Running then
		entitylib.stop()
	end

	entitylib.Connections = {
		playersService.PlayerAdded:Connect(function(player)
			entitylib.addPlayer(player)
		end),

		playersService.PlayerRemoving:Connect(function(player)
			entitylib.removePlayer(player)
		end),

		workspace:GetPropertyChangedSignal(
			'CurrentCamera'
		):Connect(function()
			gameCamera = workspace.CurrentCamera
				or workspace:FindFirstChildWhichIsA('Camera')
		end)
	}

	for _, player in playersService:GetPlayers() do
		entitylib.addPlayer(player)
	end

	entitylib.Running = true
end

entitylib.stop = function()
	for _, connection in entitylib.Connections do
		connection:Disconnect()
	end

	for _, connections in entitylib.PlayerConnections do
		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)
	end

	entitylib.removeEntity(nil, true)

	local cloned = table.clone(entitylib.List)

	for _, entity in cloned do
		entitylib.removeEntity(entity.Character)
	end

	for _, thread in entitylib.EntityThreads do
		task.cancel(thread)
	end

	table.clear(entitylib.PlayerConnections)
	table.clear(entitylib.EntityThreads)
	table.clear(entitylib.Connections)
	table.clear(cloned)

	entitylib.Running = false
end

entitylib.kill = function()
	if entitylib.Running then
		entitylib.stop()
	end

	for _, event in entitylib.Events do
		event:Destroy()
	end

	entitylib.IgnoreObject:Destroy()
	loopClean(entitylib)
end

entitylib.refresh = function()
	local cloned = table.clone(entitylib.List)

	for _, entity in cloned do
		entitylib.refreshEntity(
			entity.Character,
			entity.Player
		)
	end

	table.clear(cloned)
end

entitylib.start()

return entitylib