local mouseClicked
local inSCPRP = game.PlaceId == 5041144419 or game.PlaceId == 10953555034

local methodList = inSCPRP 
	and {'Raycast', 'Ray'} 
	or {'FindPartOnRay', 'FindPartOnRayWithIgnoreList', 'FindPartOnRayWithWhitelist', 'ScreenPointToRay', 'ViewportPointToRay', 'Raycast', 'Ray'}

local methodTooltip = inSCPRP 
	and 'Raycast - Best for shooting through walls\nRay - Hooking Ray.new, may or may not work'
	or 'FindPartOnRay* - Deprecated methods of raycasting used in old games\nRaycast - The modern raycast method\nPointToRay - Method to generate a ray from screen coords\nRay - Hooking Ray.new'

run(function()
	local SilentAim
	local Target
	local Mode
	local Method
	local MethodRay
	local IgnoredScripts
	local Range
	local HitChance
	local HeadshotChance
	local AutoFire
	local AutoFireShootDelay
	local AutoFireMode
	local AutoFirePosition
	local Wallbang
	local FunctionHook
	local OthHook
	local CircleColor
	local CircleTransparency
	local CircleFilled
	local CircleObject
	local Projectile
	local ProjectileSpeed
	local ProjectileGravity
	local RaycastWhitelist = RaycastParams.new()
	RaycastWhitelist.FilterType = Enum.RaycastFilterType.Include
	local ProjectileRaycast = RaycastParams.new()
	ProjectileRaycast.RespectCanCollide = true
	local fireoffset, rand, delayCheck = CFrame.identity, Random.new(), tick()
	local dummyCamera = Instance.new('Camera')
	local functionHookStates = {
		Normal = {},
		Oth = {}
	}
	local namecallHookStates = {}
	local othAvailable = type(oth) == 'table'
		and type(oth.hook) == 'function'

	local function getMousePosition()
		if inputService.TouchEnabled then
			return gameCamera.ViewportSize / 2
		end

		return inputService:GetMouseLocation()
	end

	local function getTarget(origin, obj)
		if rand.NextNumber(rand, 0, 100) > (AutoFire.Enabled and 100 or HitChance.Value) then return end

		local ent = entitylib['Entity'..Mode.Value]({
			Range = Range.Value,
			Wallcheck = Target.Walls.Enabled and (obj or true) or nil,
			Part = 'RootPart',
			Origin = origin,
			Players = Target.Players.Enabled,
			NPCs = Target.NPCs.Enabled
		})

		if not ent then return end

		local headshot = rand.NextNumber(rand, 0, 100) < (AutoFire.Enabled and 100 or HeadshotChance.Value)
		local targetPart = headshot and ent.Head or ent.RootPart
		targetPart = targetPart or ent.RootPart or ent.Head

		if not targetPart then return end

		targetinfo.Targets[ent] = tick() + 1

		if Projectile.Enabled then
			ProjectileRaycast.FilterDescendantsInstances = {gameCamera, ent.Character}
			ProjectileRaycast.CollisionGroup = targetPart.CollisionGroup
		end

		return ent, targetPart, origin
	end

	local Hooks = {
		FindPartOnRayWithIgnoreList = function(args)
			local ent, targetPart, origin = getTarget(args[1].Origin, {args[2]})
			if not ent then return end
			if Wallbang.Enabled then
				return {targetPart, targetPart.Position, targetPart.GetClosestPointOnSurface(targetPart, origin), targetPart.Material}
			end
			args[1] = Ray.new(origin, CFrame.lookAt(origin, targetPart.Position).LookVector * args[1].Direction.Magnitude)
		end,
		Raycast = function(args)
			if MethodRay.Value ~= 'All' and args[3] and args[3].FilterType ~= Enum.RaycastFilterType[MethodRay.Value] then return end
			local ent, targetPart, origin = getTarget(args[1])
			if not ent then return end
			args[2] = CFrame.lookAt(origin, targetPart.Position).LookVector * args[2].Magnitude
			if Wallbang.Enabled then
				RaycastWhitelist.FilterDescendantsInstances = {targetPart}
				args[3] = RaycastWhitelist
			end
		end,
		ScreenPointToRay = function(args)
			local ent, targetPart, origin = getTarget(gameCamera.CFrame.Position)
			if not ent then return end
			local direction = CFrame.lookAt(origin, targetPart.Position)
			if Projectile.Enabled then
				local calc = prediction.SolveTrajectory(origin, ProjectileSpeed.Value, ProjectileGravity.Value, targetPart.Position, targetPart.Velocity, workspace.Gravity, ent.HipHeight, nil, ProjectileRaycast)
				if not calc then return end
				direction = CFrame.lookAt(origin, calc)
			end
			return {Ray.new(origin + (args[3] and direction.LookVector * args[3] or Vector3.zero), direction.LookVector)}
		end,
		Ray = function(args)
			local ent, targetPart, origin = getTarget(args[1])
			if not ent then return end
			if Projectile.Enabled then
				local calc = prediction.SolveTrajectory(origin, ProjectileSpeed.Value, ProjectileGravity.Value, targetPart.Position, targetPart.Velocity, workspace.Gravity, ent.HipHeight, nil, ProjectileRaycast)
				if not calc then return end
				args[2] = CFrame.lookAt(origin, calc).LookVector * args[2].Magnitude
			else
				args[2] = CFrame.lookAt(origin, targetPart.Position).LookVector * args[2].Magnitude
			end
		end
	}
	Hooks.FindPartOnRayWithWhitelist = Hooks.FindPartOnRayWithIgnoreList
	Hooks.FindPartOnRay = Hooks.FindPartOnRayWithIgnoreList
	Hooks.ViewportPointToRay = Hooks.ScreenPointToRay

	local HookTargets = {
		FindPartOnRay = workspace.FindPartOnRay,
		FindPartOnRayWithIgnoreList = workspace.FindPartOnRayWithIgnoreList,
		FindPartOnRayWithWhitelist = workspace.FindPartOnRayWithWhitelist,
		ScreenPointToRay = dummyCamera.ScreenPointToRay,
		ViewportPointToRay = dummyCamera.ViewportPointToRay,
		Raycast = workspace.Raycast,
		Ray = Ray.new
	}

	local function useOthBackend()
		return OthHook and OthHook.Enabled and othAvailable or false
	end

	local function callerIsIgnored()
		local calling = getcallingscript()
		if not calling then return false end

		local list = #IgnoredScripts.ListEnabled > 0
			and IgnoredScripts.ListEnabled
			or {'CameraModule', 'ControlScript', 'ControlModule'}

		return table.find(list, tostring(calling)) ~= nil
	end

	local function installFunctionHook(methodName, useOth)
		local target = HookTargets[methodName]
		if not target then return end

		local backendName = useOth and 'Oth' or 'Normal'
		local states = functionHookStates[backendName]
		if states[target] then return end

		local state = {}
		local hooker = useOth and oth.hook or hookfunction

		state.Old = hooker(target, function(...)
			local currentMethod = Method.Value
			local currentUsesOth = useOthBackend()
			local noNamecall = currentMethod == 'Ray'

			if checkcaller()
				or not SilentAim.Enabled
				or currentMethod ~= methodName
				or currentUsesOth ~= useOth
				or (not FunctionHook.Enabled and not noNamecall)
				or callerIsIgnored() then
				return state.Old(...)
			end

			if noNamecall then
				local args = {...}
				local result = Hooks[methodName](args)

				if result then
					return unpack(result)
				end

				return state.Old(unpack(args))
			end

			local self, args = ..., {select(2, ...)}
			local result = Hooks[methodName](args)

			if result then
				return unpack(result)
			end

			return state.Old(self, unpack(args))
		end)

		states[target] = state
	end

	local function installNamecallHook(useOth)
		local backendName = useOth and 'Oth' or 'Normal'
		if namecallHookStates[backendName] then return end

		local state = {}
		local function callback(...)
			local methodName = getnamecallmethod()

			if checkcaller()
				or not SilentAim.Enabled
				or Method.Value == 'Ray'
				or methodName ~= Method.Value
				or useOthBackend() ~= useOth
				or callerIsIgnored() then
				return state.Old(...)
			end

			local self, args = ..., {select(2, ...)}
			local result = Hooks[methodName](args)

			if result then
				return unpack(result)
			end

			return state.Old(self, unpack(args))
		end

		state.Old = useOth
			and oth.hook(getrawmetatable(game).__namecall, callback)
			or hookmetamethod(game, '__namecall', callback)

		namecallHookStates[backendName] = state
	end

	SilentAim = vape.Categories.Combat:CreateModule({
		Name = 'SilentAim',
		Function = function(callback)
			if CircleObject then
				CircleObject.Visible = callback and Mode.Value == 'Mouse'
			end

			if callback then
				local methodName = Method.Value
				local useOth = useOthBackend()

				if FunctionHook.Enabled or methodName == 'Ray' then
					installFunctionHook(methodName, useOth)
				end

				if methodName ~= 'Ray' then
					installNamecallHook(useOth)
				end

				repeat
					if CircleObject then
						CircleObject.Position = getMousePosition()
					end

					if AutoFire.Enabled then
						local origin = AutoFireMode.Value == 'Camera' and gameCamera.CFrame or entitylib.isAlive and entitylib.character.RootPart.CFrame or CFrame.identity
						local ent = entitylib['Entity'..Mode.Value]({
							Range = Range.Value,
							Wallcheck = Target.Walls.Enabled or nil,
							Part = 'RootPart',
							Origin = (origin * fireoffset).Position,
							Players = Target.Players.Enabled,
							NPCs = Target.NPCs.Enabled
						})

						if mouse1click and (isrbxactive or iswindowactive)() then
							if ent and canClick() then
								if delayCheck < tick() then
									if mouseClicked then
										mouse1release()
										delayCheck = tick() + AutoFireShootDelay.Value
									else
										mouse1press()
									end
									mouseClicked = not mouseClicked
								end
							else
								if mouseClicked then
									mouse1release()
								end
								mouseClicked = false
							end
						end
					end

					task.wait()
				until not SilentAim.Enabled

				if mouseClicked then
					pcall(mouse1release)
					mouseClicked = false
				end
			else
				if mouseClicked then
					pcall(mouse1release)
					mouseClicked = false
				end
			end
		end,
		ExtraText = function()
			return Method.Value:gsub('FindPartOnRay', '')
		end,
		Tooltip = 'Silently adjusts your aim towards the enemy'
	})

	Target = SilentAim:CreateTargets({Players = true})

	Mode = SilentAim:CreateDropdown({
		Name = 'Mode',
		List = {'Mouse', 'Position'},
		Function = function(val)
			if CircleObject then
				CircleObject.Visible = SilentAim.Enabled and val == 'Mouse'
			end
		end,
		Tooltip = 'Mouse - Checks for entities near the mouses position\nPosition - Checks for entities near the local character'
	})

	Method = SilentAim:CreateDropdown({
		Name = 'Method',
		List = methodList,
		Function = function(val)
			if SilentAim.Enabled then
				SilentAim:Toggle()
				SilentAim:Toggle()
			end
			if MethodRay and MethodRay.Object then
				MethodRay.Object.Visible = val == 'Raycast'
			end
		end,
		Tooltip = methodTooltip,
	})

	MethodRay = SilentAim:CreateDropdown({
		Name = 'Raycast Type',
		List = {'All', 'Exclude', 'Include'},
		Darker = true,
		Visible = false
	})

	IgnoredScripts = SilentAim:CreateTextList({
		Name = 'Ignored Scripts',
		Default = {'CameraModule'}
	})

	Range = SilentAim:CreateSlider({
		Name = 'Range',
		Min = 1,
		Max = 1000,
		Default = 150,
		Function = function(val)
			if CircleObject then
				CircleObject.Radius = val
			end
		end,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})

	HitChance = SilentAim:CreateSlider({
		Name = 'Hit Chance',
		Min = 0,
		Max = 100,
		Default = 85,
		Suffix = '%'
	})

	HeadshotChance = SilentAim:CreateSlider({
		Name = 'Headshot Chance',
		Min = 0,
		Max = 100,
		Default = 65,
		Suffix = '%'
	})

	AutoFire = SilentAim:CreateToggle({
		Name = 'AutoFire',
		Function = function(callback)
			AutoFireShootDelay.Object.Visible = callback
			AutoFireMode.Object.Visible = callback
			AutoFirePosition.Object.Visible = callback
		end
	})

	AutoFireShootDelay = SilentAim:CreateSlider({
		Name = 'Next Shot Delay',
		Min = 0,
		Max = 1,
		Decimal = 100,
		Visible = false,
		Darker = true,
		Suffix = function(val)
			return val == 1 and 'second' or 'seconds'
		end
	})

	AutoFireMode = SilentAim:CreateDropdown({
		Name = 'Origin',
		List = {'RootPart', 'Camera'},
		Visible = false,
		Darker = true,
		Tooltip = 'Determines the position to check for before shooting'
	})

	AutoFirePosition = SilentAim:CreateTextBox({
		Name = 'Offset',
		Function = function()
			local suc, res = pcall(function()
				return CFrame.new(unpack(AutoFirePosition.Value:split(',')))
			end)
			if suc then fireoffset = res end
		end,
		Default = '0, 0, 0',
		Visible = false,
		Darker = true
	})

	Wallbang = SilentAim:CreateToggle({
		Name = 'Wallbang'
	})

	FunctionHook = SilentAim:CreateToggle({
		Name = 'Function hook',
		Function = function()
			if SilentAim.Enabled then
				SilentAim:Toggle()
				SilentAim:Toggle()
			end
		end,
		Tooltip = 'Hooks direct index calls such as workspace.Raycast (used by some games)'
	})

	OthHook = SilentAim:CreateToggle({
		Name = 'Oth hook',
		Function = function()
			if SilentAim.Enabled then
				SilentAim:Toggle()
				SilentAim:Toggle()
			end
		end,
		Tooltip = othAvailable
			and 'Uses the Oth hook backend for games that check normal metamethod hooks'
			or 'Oth is unavailable in this executor; the normal hook backend will be used'
	})

	SilentAim:CreateToggle({
		Name = 'Range Circle',
		Function = function(callback)
			if callback then
				CircleObject = Drawing.new('Circle')
				CircleObject.Filled = CircleFilled.Enabled
				CircleObject.Color = Color3.fromHSV(CircleColor.Hue, CircleColor.Sat, CircleColor.Value)
				CircleObject.Position = getMousePosition()
				CircleObject.Radius = Range.Value
				CircleObject.NumSides = 100
				CircleObject.Transparency = 1 - CircleTransparency.Value
				CircleObject.Visible = SilentAim.Enabled and Mode.Value == 'Mouse'
			else
				pcall(function()
					CircleObject.Visible = false
					CircleObject:Remove()
				end)
				CircleObject = nil
			end
			CircleColor.Object.Visible = callback
			CircleTransparency.Object.Visible = callback
			CircleFilled.Object.Visible = callback
		end
	})

	CircleColor = SilentAim:CreateColorSlider({
		Name = 'Circle Color',
		Function = function(hue, sat, val)
			if CircleObject then
				CircleObject.Color = Color3.fromHSV(hue, sat, val)
			end
		end,
		Darker = true,
		Visible = false
	})

	CircleTransparency = SilentAim:CreateSlider({
		Name = 'Transparency',
		Min = 0,
		Max = 1,
		Decimal = 10,
		Default = 0.5,
		Function = function(val)
			if CircleObject then
				CircleObject.Transparency = 1 - val
			end
		end,
		Darker = true,
		Visible = false
	})

	CircleFilled = SilentAim:CreateToggle({
		Name = 'Circle Filled',
		Function = function(callback)
			if CircleObject then
				CircleObject.Filled = callback
			end
		end,
		Darker = true,
		Visible = false
	})

	Projectile = SilentAim:CreateToggle({
		Name = 'Projectile',
		Function = function(callback)
			ProjectileSpeed.Object.Visible = callback
			ProjectileGravity.Object.Visible = callback
		end
	})

	ProjectileSpeed = SilentAim:CreateSlider({
		Name = 'Speed',
		Min = 1,
		Max = 1000,
		Default = 1000,
		Darker = true,
		Visible = false,
		Suffix = function(val)
			return val == 1 and 'stud' or 'studs'
		end
	})

	ProjectileGravity = SilentAim:CreateSlider({
		Name = 'Gravity',
		Min = 0,
		Max = 192.6,
		Default = 192.6,
		Darker = true,
		Visible = false
	})
end)
